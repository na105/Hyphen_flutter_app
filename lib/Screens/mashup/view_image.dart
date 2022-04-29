import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyphen/model/global.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../../providers/safe_provider.dart';
import '../canvas/image_canvas.dart';

class ViewImage extends StatefulWidget {
  method() => createState().viewFullImages();

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage>
    with SingleTickerProviderStateMixin {
  PaletteGenerator? paletteGenerator;
  Color? accent = Colors.transparent;
  List<Color?>? colors;
  bool clicked = false;
  var url = Uri.parse(Global.photos[Global.index].src!.portrait.toString());

  PageController pageController = PageController(initialPage: Global.index);

  final provider = new SafeProvider();

  @override
  void initState() {
    super.initState();

    _requestPermission();

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
  Widget build(BuildContext context) {
    return showImageFull();
  }

  showImageFull() {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: FutureBuilder(
          future: _loadColorsPalett(Global.photos[Global.index].src!.tiny!),
          builder: (context, snapshot) {
            return Stack(
              children: [
                viewFullImages(),
                _crearteButtons(size, provider),
                _getPreviousScreen(size),
              ],
            );
          },
        ),
      ),
    );
  }

  SafeArea _getPreviousScreen(Size size) {
    return SafeArea(
      child: Container(
          padding: EdgeInsets.only(top: 4, left: 15, right: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: accent,
                  size: 24,
                ),
              ),
            ],
          )),
    );
  }

  FutureBuilder _crearteButtons(Size size, SafeProvider provider) {
    return FutureBuilder(
      future: provider.initiateStream(),
      builder: (context, snapshot) {
        return StreamBuilder(
          stream: provider.statesStream,
          builder: (context, AsyncSnapshot<Object?> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return CircularCustomProgress();
              }
              return _buttons(size);
            }
            return CircularCustomProgress();
          },
        );
      },
    );
  }

  Container _buttons(Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _setUsePcture(size),
          SizedBox(width: 10),
          _downloadPicture(size),
        ],
      ),
    );
  }

  Container _setUsePcture(Size size) {
    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(horizontal: size.width / 8),
      child: ElevatedButton(
          child: Text("Use picture in canvas",
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
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImageCanvas(
                          image: Global.photos[Global.index].src!.large2x!,
                        )));
          }),
    );
  }

  _downloadPicture(Size size){
    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(horizontal: size.width / 8),
      child: ElevatedButton(
        onPressed: () async {
          if (await provider.checkStoragePermissions()) {
            downloadImage();
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

  Future downloadImage() async {
    var response = await Dio().get(
      Global.photos[Global.index].src!.portrait.toString(),
      options: Options(responseType: ResponseType.bytes)
    );
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      quality: 80,
      name: Global.photos[Global.index].photographer
    );
    print(result);
    _toastInfo('Downloaded Successfully');
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

  Container viewFullImages() {
    return Container(
      child: Hero(
        tag: '$Global.index',
        child: Container(
          child: CachedNetworkImage(
            filterQuality: FilterQuality.high,
            imageUrl: Global.photos[Global.index].src!.portrait!,
            height: 900,
            width: 420,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.white24,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
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
      padding: EdgeInsets.only(bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircularProgressIndicator(),
        ],
      ),
    ));
  }
}
