import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SafeProvider {
  static const platform = const MethodChannel('setMyImagesAsWallpaper');

  //stream the current state 
  final _stateStreamController = StreamController<bool>.broadcast();

  //adding data to stream
  Function(bool) get stateSink => _stateStreamController.sink.add;

  //funcion to return the constant info
  Stream<bool> get statesStream => _stateStreamController.stream;

  void disposeStreams() {
    _stateStreamController.close();
  }

  initiateStream() async {
    await Future.delayed(Duration(milliseconds: 200));
    await stateSink(false);
  }

  Future<bool> downloadIMG(var getImage, String number) async {
    await stateSink(true);
    try {
      await Future.delayed(Duration(milliseconds: 1500));
      await platform.invokeMethod(
          "download_image_dm", {'link': getImage, 'filename': number});
      await stateSink(false);
      return true;
    } on PlatformException catch (e) {
      print("error: $e");
    }
    await stateSink(false);
    return false;
  }

  Future<bool> checkStoragePermissions() async {
    if (await Permission.storage.status.isDenied) {
      await Permission.storage.request();
      return false;
    }
    return true;
  }
}
