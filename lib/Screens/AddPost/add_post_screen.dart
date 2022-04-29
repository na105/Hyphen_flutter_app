import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyphen/components/input_container.dart';
import 'package:hyphen/components/rounded_button.dart';
import 'package:hyphen/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../components/app_bar.dart';
import '../../providers/user_provider.dart';
import '../../resources/firestore_methods.dart';
import '../../utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  int mashable = 1;

  _selectImage(ImageSource source) async {
    Uint8List file = await pickImage(source);
    if (file != null) {
      setState(() {
        _file = file;
      });
    } else {
      return;
    }
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
          _descriptionController.text,
          _file!,
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
        clearImage();
      } else {
        showSnackbar(context, res);
        setState(() {
          isLoading = false;
        });
        clearImage();
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

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _file == null
        ? Scaffold(
            extendBodyBehindAppBar: false,
            body: CustomScrollView(
              slivers: [
                appBar(),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Title(
                              color: Color(0xFF182F50),
                              child: Text(
                                'Add media to your account',
                                style: TextStyle(
                                  color: Color(0xFF182F50),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              )),
                          Container(
                              height: 320,
                              width: 300,
                              alignment: Alignment.centerRight,
                              color: Colors.transparent,
                              child:
                                  SvgPicture.asset('assets/images/post.svg')),
                          SizedBox(height: 5),
                          InputContainer(
                            child: InkWell(
                              onTap: () async {
                                _selectImage(ImageSource.camera);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.camera_alt_outlined, size: 35),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  Text('Take a Picture',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          InputContainer(
                            child: InkWell(
                              onTap: () async {
                                _selectImage(ImageSource.gallery);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.image_outlined, size: 35),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  Text('Choose from Gallery',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]))
              ],
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Scaffold(
                body: CustomScrollView(slivers: [
              SliverAppBar(
                  pinned: false,
                  floating: true,
                  backgroundColor: kPrimaryColor,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: clearImage,
                  ),
                  title: Text(
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
                            child: Image.asset(
                                'assets/images/logo-darkTheme.png')),
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
                                      image: MemoryImage(_file!),
                                    )),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      userProvider.getUser.photoUrl,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      child: InputContainer(
                                          child: TextFormField(
                                        cursorColor: kPrimaryColor,
                                        decoration: InputDecoration(
                                            hintText: 'Write a caption',
                                            border: InputBorder.none),
                                        controller: _descriptionController,
                                        maxLines: 8,
                                      ))),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Column(children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
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
                                          color: Colors.grey.shade600,
                                          size: 25),
                                      alignment: Alignment.topLeft,
                                      onPressed: () {
                                        _returnBackToOldScreen();
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
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
                              SizedBox(
                                height: 25,
                              ),
                              RoundedButton(
                                  onTap: () {
                                    postImage(
                                        userProvider.getUser.uid,
                                        userProvider.getUser.username,
                                        userProvider.getUser.photoUrl);
                                  },
                                  child: InkWell(
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
            ])),
          );
  }

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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                        )
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 40),
                      child: Text(
                          'Your media would be accessible for other users to use and post on their respective accounts. \n\n Their media would include your account for reference',
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFF182F50)),
                          textAlign: TextAlign.center),
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
}
