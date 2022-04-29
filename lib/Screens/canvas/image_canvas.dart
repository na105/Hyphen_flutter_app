import 'dart:io';
import 'dart:typed_data';

import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:hyphen/model/global.dart';
import 'package:hyphen/providers/user_provider.dart';
import 'package:hyphen/responsive/mobile_screen_layou.dart';
import 'package:hyphen/responsive/responsive_layout_screen.dart';
import 'package:hyphen/responsive/web_screen_layout.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stack_board/stack_board.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../components/input_container.dart';
import '../../components/rounded_button.dart';
import '../../constants.dart';
import '../../model/rooms.dart';
import '../../providers/room_provider.dart';
import '../../providers/safe_provider.dart';
import '../../resources/firestore_methods.dart';
import '../../resources/rooms_methods.dart';
import '../../utils/utils.dart';
import '../mashup/view_image.dart';

class ImageCanvas extends StatefulWidget {
  final String image;
  const ImageCanvas({Key? key, required this.image}) : super(key: key);

  @override
  _ImageCanvasState createState() => _ImageCanvasState();
}

class _ImageCanvasState extends State<ImageCanvas>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  late StackBoardController _boardController;
  Color color = Colors.white;
  late File image;
  late GiphyGif _gif;
  late ScreenshotController screenshotController;
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController =
      TextEditingController();
  final provider = SafeProvider();
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  int mashable = 1;
  PhotoViewScaleStateController? scaleStateController;

  late RoomProvider roomProvider;
  late UserProvider userProvider;

  @override
  void initState() {
    _boardController = StackBoardController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    screenshotController = ScreenshotController();
    scaleStateController = PhotoViewScaleStateController();
    super.initState();
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    _toastInfo(info);
  }
  
  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

  @override
  void dispose() {
    _boardController.dispose();
    _descriptionController.dispose();
    scaleStateController!.dispose();
    super.dispose();
  }

  void postImage(
      String uid, String username, String profImage, Uint8List file) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
          _descriptionController.text,
          file,
          uid,
          username,
          profImage,
          mashable);
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackbar(
          context,
          'Posted!',
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const ResponsiveLayout(
                      mobileScreenLayout: MobileScreenLayout(),
                      webScreenLayout: WebScreenLayout(),
                    )));
      } else {
        showSnackbar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackbar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    roomProvider = Provider.of<RoomProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          backgroundColor: color,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF182F50)),
              onPressed: () {
                _returnBackToOldScreen();
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  alignment: Alignment.centerLeft,
                ),
              ],
            ),
          ),
          body: Screenshot(
              child: Container(
                child: StackBoard(
                  controller: _boardController,
                ),
              ),
              controller: screenshotController),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

          //Init Floating Action Bubble
          floatingActionButton: FloatingActionBubble(
            // Menu items
            items: <Bubble>[
              // Floating action menu item
              Bubble(
                title: "Text",
                iconColor: Colors.white,
                bubbleColor: const Color(0xFF182F50),
                icon: Icons.text_format_outlined,
                titleStyle: const TextStyle(fontSize: 18, color: Colors.white),
                onPress: () {
                  _boardController.add(
                    const AdaptiveText(
                      'Click to text',
                      tapToEdit: true,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                  _animationController.reverse();
                },
              ),
              // Floating action menu item
              Bubble(
                title: "Draw",
                iconColor: Colors.white,
                bubbleColor: const Color(0xFF182F50),
                icon: Icons.brush,
                titleStyle: const TextStyle(fontSize: 18, color: Colors.white),
                onPress: () {
                  _boardController.add(const StackDrawing());
                  _animationController.reverse();
                },
              ),
              Bubble(
                title: "Insert gif",
                iconColor: Colors.white,
                bubbleColor: const Color(0xFF182F50),
                icon: Icons.sticky_note_2_sharp,
                titleStyle: const TextStyle(fontSize: 18, color: Colors.white),
                onPress: () async {
                  // request your Giphy API key at https://developers.giphy.com/
                  final gif = await GiphyPicker.pickGif(
                    context: context,
                    apiKey: 'DHAujoeNNdFhyWBatRzmSaJSoYrE3Lm3',
                    fullScreenDialog: false,
                    previewType: GiphyPreviewType.previewWebp,
                    decorator: GiphyDecorator(
                      showAppBar: false,
                      searchElevation: 4,
                      giphyTheme: ThemeData.light().copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  );
                  if (gif != null) {
                    setState(() => _gif = gif);
                  } else {
                    return;
                  }
                  _boardController.add(StackBoardItem(
                      child:
                          GiphyImage.original(gif: _gif, fit: BoxFit.cover)));

                  _animationController.reverse();
                },
              ),
              Bubble(
                title: "Background",
                iconColor: Colors.white,
                bubbleColor: const Color(0xFF182F50),
                icon: Icons.format_color_fill_outlined,
                titleStyle: const TextStyle(fontSize: 18, color: Colors.white),
                onPress: () {
                  pickColor(context);
                  _animationController.reverse();
                },
              ),
              Bubble(
                title: "Clear canvas",
                iconColor: Colors.white,
                bubbleColor: const Color(0xFF182F50),
                icon: Icons.clear,
                titleStyle: const TextStyle(fontSize: 18, color: Colors.white),
                onPress: () {
                  _boardController.clear();
                  _animationController.reverse();
                },
              ),
              Bubble(
                title: "Import Photos",
                iconColor: Colors.white,
                bubbleColor: const Color(0xFF182F50),
                icon: Icons.linked_camera_rounded,
                titleStyle: const TextStyle(fontSize: 18, color: Colors.white),
                onPress: () async {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image == null) return;
                  final imageTemp = File(image.path);
                  if (imageTemp != null) {
                    setState(() {
                      this.image = imageTemp;
                    });
                  } else {
                    return;
                  }
                  _boardController.add(StackBoardItem(
                      child: Image.file(this.image, fit: BoxFit.cover)));
                  _animationController.reverse();
                },
              ),
              //Floating action menu item
              Bubble(
                title: " Display media ",
                iconColor: Colors.white,
                bubbleColor: const Color(0xFF182F50),
                icon: Icons.photo_camera_back_sharp,
                titleStyle: const TextStyle(fontSize: 18, color: Colors.white),
                onPress: () {
                  screenshotController
                      .capture(delay: const Duration(milliseconds: 10))
                      .then((capturedImage) async {
                    ShowCapturedWidget(context, capturedImage!, userProvider);
                  }).catchError((onError) {
                    print(onError);
                  });
                  _animationController.reverse();
                },
              ),
              Bubble(
                  icon: Icons.image,
                  iconColor: Colors.white,
                  title: 'Background Image',
                  titleStyle: const TextStyle(fontSize: 18, color: Colors.white),
                  bubbleColor: kPrimaryColor,
                  onPress: () {
                    _boardController.add(
                        StackBoardItem(child: Image.network(widget.image)));
                    _animationController.reverse();
                  }),
            ],

            // animation controller
            animation: _animation,

            // On pressed change animation state
            onPress: () => _animationController.isCompleted
                ? _animationController.reverse()
                : _animationController.forward(),

            // Floating Action button Icon color
            iconColor: Colors.white,

            // Flaoting Action button Icon
            iconData: Icons.add,
            backGroundColor: const Color(0xFF182F50),
          )),
    );
  }

  void leaveGroup() {
    roomProvider.room.members.removeWhere(
          (element) {
        return element == userProvider.getUser.uid;
      },
    );

    if (roomProvider.room.members.isEmpty) {
      RoomsMethods().deleteRoom(roomProvider.room);
    }

    uploadPostToFireStore(roomProvider.room);
  }

  void uploadPostToFireStore(Rooms room) {
    RoomsMethods roomsMethods = RoomsMethods();
    roomsMethods.updateRoom(room);
  }

  Widget buildColorPicker() => ColorPicker(
        pickerColor: color,
        onColorChanged: (color) => setState(() {
          this.color = color;
        }),
      );

  void pickColor(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Pick a Color'),
            content: Column(
              children: [
                buildColorPicker(),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'SELECT',
                      style: TextStyle(fontSize: 20),
                    )),
              ],
            ),
          ));

  Future<bool> _returnBackToOldScreen() async {
    final bool? r = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Center(
          child: SizedBox(
            width: 400,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 40),
                      child: Text(
                        'Are you sure you want to leave? \n Your work will be deleted',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF182F50),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                            onPressed: () => setState(() {
                              leaveGroup();

                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ResponsiveLayout(
                                                mobileScreenLayout:
                                                    MobileScreenLayout(),
                                                webScreenLayout:
                                                    WebScreenLayout(),
                                              )));
                                }),
                            icon: const Icon(Icons.check, size: 30)),
                        IconButton(
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(Icons.clear, size: 30)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    return r ?? false;
  }

  Future<dynamic> ShowCapturedWidget(BuildContext context,
      Uint8List capturedImage, UserProvider userProvider) {
    final size = MediaQuery.of(context).size;
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        body: Stack(
          children: [
            Center(
                child: capturedImage != null
                    ? Image.memory(capturedImage)
                    : Container()),
            _crearteButtons(size, provider, capturedImage, userProvider),
            _getPreviousScreen(size),
          ],
        ),
      ),
    );
  }

  FutureBuilder _crearteButtons(Size size, SafeProvider provider,
      Uint8List capturedImage, UserProvider userProvider) {
    return FutureBuilder(
      future: provider.initiateStream(),
      builder: (context, snapshot) {
        return StreamBuilder(
          stream: provider.statesStream,
          builder: (context, AsyncSnapshot<Object?> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return const CircularCustomProgress();
              }
              return _buttons(size, capturedImage, userProvider);
            }
            return const CircularCustomProgress();
          },
        );
      },
    );
  }

  Container _buttons(
      Size size, Uint8List capturedImage, UserProvider userProvider) {
    return Container(
      width: size.width,
      margin: const EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _setPostPcture(size, capturedImage, userProvider),
          const SizedBox(width: 10),
          _downloadPicture(size, capturedImage),
        ],
      ),
    );
  }

  Container _setPostPcture(
      Size size, Uint8List capturedImage, UserProvider userProvider) {
    return Container(
      width: 350,
      height: 45,
      margin: EdgeInsets.symmetric(horizontal: size.width / 8),
      child: ElevatedButton(
          child: const Text("Post on your account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.all(const Color(0xFF182F50).withOpacity(0.6)),
          ),
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        displayPostScreen(capturedImage, userProvider)));
          }),
    );
  }

  _downloadPicture(Size size, Uint8List capturedImage){
    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(horizontal: size.width / 8),
      child: ElevatedButton(
        onPressed: () async {
          if (await _requestPermission()) {
            downloadImage(capturedImage);
          }
        },
        child: Text('Download image',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all(Color(0xFF182F50).withOpacity(0.6)),
        ),
      ),
    );
  }

  Future downloadImage(Uint8List capturedImage) async {
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(capturedImage),
      quality: 80,
      name: Global.photos[Global.index].photographer
    );
    print(result);
    _toastInfo('Downloaded Successfully');
  }

  displayPostScreen(Uint8List capturedImage, UserProvider userProvider) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
          pinned: false,
          floating: true,
          backgroundColor: kPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'New Post',
            textAlign: TextAlign.start,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    alignment: Alignment.centerRight,
                    color: Colors.transparent,
                    child: Image.asset('assets/images/logo-darkTheme.png')),
              ],
            )
          ]),
      SliverList(
        delegate: SliverChildListDelegate(
          [
            //POST Form
            Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                const Divider(),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 230.0,
                        width: 150.0,
                        child: AspectRatio(
                          aspectRatio: 300 / 300,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              fit: BoxFit.fill,
                              alignment: FractionalOffset.topCenter,
                              image: MemoryImage(capturedImage),
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              userProvider.getUser.photoUrl,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.1,
                              child: InputContainer(
                                  child: TextFormField(
                                cursorColor: kPrimaryColor,
                                decoration: const InputDecoration(
                                    hintText: 'Write a caption',
                                    border: InputBorder.none),
                                controller: _descriptionController,
                                maxLines: 8,
                              ))),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Would you like your media to be \n mashable?',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF182F50),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            IconButton(
                              icon: Icon(Icons.info,
                                  color: Colors.grey.shade600, size: 25),
                              alignment: Alignment.topLeft,
                              onPressed: () {
                                _returnBackToOldScreen();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ToggleSwitch(
                          minWidth: 110.0,
                          cornerRadius: 20.0,
                          activeBgColors: [
                            [Colors.green[800]!],
                            [Colors.red[800]!]
                          ],
                          activeFgColor: Colors.white,
                          inactiveBgColor: Colors.grey,
                          inactiveFgColor: Colors.white,
                          fontSize: 16,
                          initialLabelIndex: 1,
                          totalSwitches: 2,
                          labels: ['Mashable', 'Unmashable'],
                          radiusStyle: true,
                          onToggle: (index) {
                            mashable = index!;
                            print('$index');
                          },
                        ),
                      ]),
                      const SizedBox(
                        height: 25,
                      ),
                      RoundedButton(
                          onTap: () {
                            postImage(
                                userProvider.getUser.uid,
                                userProvider.getUser.username,
                                userProvider.getUser.photoUrl,
                                capturedImage);
                          },
                          child: const InkWell(
                            child: Text('POST',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ))
                    ]),
              ],
            ),
            const Divider(),
          ],
        ),
      )
    ]));
  }

  SafeArea _getPreviousScreen(Size size) {
    return SafeArea(
      child: Container(
          padding: const EdgeInsets.only(top: 4, left: 15, right: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF182F50),
                  size: 35,
                ),
              ),
            ],
          )),
    );
  }
}

class CircularCustomProgress extends StatelessWidget {
  const CircularCustomProgress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const CircularProgressIndicator(),
        ],
      ),
    ));
  }
}
