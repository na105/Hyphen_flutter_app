import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:hyphen/model/global.dart';
import 'package:hyphen/model/imagesList_model.dart';
import 'dart:convert';


class PexelsProvider {
  TextEditingController _textcontroller = new TextEditingController();
  bool _search = false;
  int _page = 1;
  int _perPage = 6;
  List<ImagesListModel> _photos = [];
  bool _loading = false;
  String key = "563492ad6f917000010000015c3eb7da2e6848a6ab292eb2eb354c43";
  String topic = "";
  final _topics = <String>[
    "Art",
    "Logos",
    "Space",
    "Social Media",
    "Technology",
    "Cars",
    "Nature",
    "Cities",
    "Street Art",
    "Wild Life",
    "Motivation",
    'Abstract',
    'Classic',
    'Damask',
    'Geometric',
    'Brick',
    'Concrete',
    'Wood',
    'Floral',
    'Modern',
    'Transition',
  ];

  final _photosStreamController = StreamController<List<ImagesListModel>>.broadcast();

  Function(List<ImagesListModel>) get photosSink => _photosStreamController.sink.add;

  Stream<List<ImagesListModel>> get photosStream => _photosStreamController.stream;

  void disposeStreams() {
    _photosStreamController.close();
  }

  getTopics() {
    return this._topics;
  }

  getLoading() {
    return this._loading;
  }

  setLoading(bool c) {
    this._loading = c;
  }

  setStateSearch() {
    this._search = !_search;
  }

  getStateSearch() {
    return this._search;
  }

  getPage() {
    return this._page;
  }

  setPage(int i) {
    this._page = i;
  }

  getTextController() {
    return this._textcontroller;
  }

  setTextController(String text) {
    this._textcontroller.text = text;
  }

  //initial wallpapers
  Future<bool> getInitialWallpaper() async {
    try {
      var random = new Random();
      int randomNumber = random.nextInt(this._topics.length);
      topic = this._topics[randomNumber];
      final result = await http.get(
          Uri.parse(
              "https://api.pexels.com/v1/search?query=$topic&page=$_page&per_page=$_perPage"),
          headers: {"Authorization": key});

      final decoded = json.decode(result.body);

      for (var i in decoded['photos']) {
        var a = ImagesListModel.fromMap(i);
        _photos.add(a);
      }
      Global.photos = _photos;
      photosSink(_photos);
      return true;
    } catch (e) {
      return false;
    }
  }

  //update when list is on bottom
  Future<void> seartchNextPage() async {
    try {
      if (_loading) {
        return;
      }
      _loading = true;

      final result = await http.get(
          Uri.parse(
              "https://api.pexels.com/v1/search?query=$topic&page=$_page&per_page=$_perPage"),
          headers: {"Authorization": key});

      final decoded = json.decode(result.body);

      for (var i in decoded['photos']) {
        var a = ImagesListModel.fromMap(i);
        _photos.add(a);
      }
      _page++;
      Global.photos = _photos;
      photosSink(_photos);

      _loading = false;
    } catch (e) {
      _loading = false;
    }
  }

  Future<void> searchFromTextField() async {
    try {
      if (_loading) {
        return;
      }
      if (_textcontroller.text.isEmpty) {
        
      } 
      else {
        _loading = true;
        _photos = [];
        Global.photos = [];
        photosSink(_photos);
        setPage(1);
        this.topic = _textcontroller.text;

        final result = await http.get(
            Uri.parse(
                "https://api.pexels.com/v1/search?query=${_textcontroller.text}"),
            headers: {"Authorization": key});
        final decoded = json.decode(result.body);

        for (var i in decoded['photos']) {
          var a = ImagesListModel.fromMap(i);
          _photos.add(a);
        }
        _page++;
        Global.photos = _photos;
        photosSink(_photos);
        _textcontroller.clear();


        _loading = false;
      }
    } catch (e) {
      _loading = false;
    }
  }

  Future<void> searchFromCategory(String txt) async {
    try {
      if (_loading) {
        return;
      }
      _loading = true;
      _photos = [];
      Global.photos = [];
      photosSink(_photos);
      setPage(1);
      this.topic = txt;
      final respuesta = await http.get(
          Uri.parse("https://api.pexels.com/v1/search?query=$txt"),
          headers: {"Authorization": key});

      final decoded = json.decode(respuesta.body);

      for (var i in decoded['photos']) {
        var a = ImagesListModel.fromMap(i);
        _photos.add(a);
      }
      _page++;
      Global.photos = _photos;
      photosSink(_photos);
      _textcontroller.clear();
      _loading = false;
    } catch (e) {
      _loading = false;
    }
  }
  //
}
