import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyphen/Screens/canvas/mashup_canvas_screen.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../model/rooms.dart';
import '../../providers/room_provider.dart';
import '../../providers/user_provider.dart';
import '../../resources/rooms_methods.dart';

class ViewMashupImageScreen extends StatefulWidget {
  final String url;
  const ViewMashupImageScreen({ Key? key, required this.url }) : super(key: key);

  @override
  _ViewMashupImageScreenState createState() => _ViewMashupImageScreenState();
}

class _ViewMashupImageScreenState extends State<ViewMashupImageScreen> {
  PaletteGenerator? paletteGenerator;
  Color? accent = Colors.transparent;
  List<Color?>? colors;
  bool clicked = false;

  late RoomProvider roomProvider;
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {

    userProvider = Provider.of<UserProvider>(context);
    roomProvider = Provider.of<RoomProvider>(context);

    return showImageFull();
  }

  showImageFull(){
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async{ return false; },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  // leaveGroup();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: kPrimaryColor)
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: 110,
                      width: 130,
                      alignment: Alignment.centerRight,
                      color: Colors.transparent,
                      child: SvgPicture.asset('assets/images/logo.svg')),
                ],
              ),
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance
                  .collection('posts')
                  .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
            return viewFullImages();
          },
        ),
      ),
    );
  }

  void leaveGroup() {
    roomProvider.room.members.removeWhere(
          (element) {
        return element == userProvider.getUser.uid;
      },
    );

    uploadPostToFireStore(roomProvider.room);

    if (roomProvider.room.members.isEmpty) {
      RoomsMethods().deleteRoom(roomProvider.room);
    }
  }

  void uploadPostToFireStore(Rooms room) {
    RoomsMethods roomsMethods = RoomsMethods();
    roomsMethods.updateRoom(room);
  }

  Stack viewFullImages() {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Hero(
              tag: 'photo URL',
              child: CachedNetworkImage(
                filterQuality: FilterQuality.high,
                imageUrl: widget.url,
                height: 900,
                width: 420,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.white24,
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
        _buttons(size)
      ],
    );
      }
  


  Container _buttons(Size size) {
    return Container(
      width: size.width,
      margin: const EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _setUsePcture(size),
        ],
      ),
    );
  }

  Container _setUsePcture(Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(horizontal: size.width / 8),
      child: ElevatedButton(
          child: const Text("Use picture in canvas", style: TextStyle(fontSize: 16, fontWeight:FontWeight.bold)),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => MashupCanvasScreen(image: widget.url,)));           
          }),
    );
  }

  Future<void> _loadColorsPalett(String url) async {
    paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(url),
    );
    colors = paletteGenerator!.colors.toList();

    if (paletteGenerator!.colors.length > 5) {
      colors = colors!.sublist(0, 5);
    }
    accent = colors![0];
    if (accent!.computeLuminance() > 0.5) {
      //for white imgages
      accent = Colors.black;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
          .copyWith(statusBarIconBrightness: Brightness.dark));
    } else {
      //for black imgages
      accent = Colors.white;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
          .copyWith(statusBarIconBrightness: Brightness.light));
    }

    return;
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
        children: const [
          CircularProgressIndicator(),
        ],
      ),
    ));
  }
}