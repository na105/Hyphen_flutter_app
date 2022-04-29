import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyphen/model/rooms.dart';

import '../resources/auth_methods.dart';

class RoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rooms? _rooms;
  final AuthMethods _authMethods = AuthMethods();

  Rooms get room => _rooms!;
  List<Rooms>? roomsList;

  set room(Rooms rooms) {
    _rooms = rooms;
    notifyListeners();
  }

  Future<Rooms> getRoom(String roomUId) {
    return _firestore
        .collection('rooms')
        .doc(roomUId)
        .get()
        .then((value) => Rooms.fromSnap(value));
  }

  Future<List<Rooms>> getAllRooms() {
    return _firestore
        .collection('rooms')
        .get()
        .then((value) {
      List<Rooms> rooms = [];
      for (var room in value.docs) {
        rooms.add(Rooms.fromMap(room.data()));
        print(room.data());
      }
      roomsList = rooms;
      notifyListeners();
      return rooms;
    });
  }
}
