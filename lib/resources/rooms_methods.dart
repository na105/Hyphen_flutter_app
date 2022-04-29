import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/rooms.dart';

class RoomsMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // create a mashup room
  Future<Rooms?> createRoom(
    String roomName,
    String uid,
    String username,
    List<String> members,
  ) async {
    String res = 'Some error occurred';
    // String roomId = const Uuid().v1(); // create unique room Id

    Rooms room = Rooms(
      roomName: roomName,
      roomId: '',
      uid: uid,
      activeUser: username,
      username: username,
      members: members,
    );

    bool userExists = (await _firestore.collection('rooms').doc(roomName).get()).exists;
    if(userExists)
      return null;

    DocumentReference reference = _firestore.collection('rooms').doc(roomName);
    room.roomId = reference.id;
    await reference.set(room.toJson());

    // await _firestore.collection('rooms').doc().set(room.toJson());
    return room;
  }

  Future<Rooms> getRoom(String roomUId) {
    return _firestore
        .collection('rooms')
        .doc(roomUId)
        .get()
        .then((value) => Rooms.fromSnap(value));
  }

  void updateRoom(Rooms room) async {
    await _firestore.collection('rooms').doc(room.roomName).update(room.toJson());
  }

  void deleteRoom(Rooms room) async {
    await _firestore.collection('rooms').doc(room.roomId).delete();
  }

  Stream<Rooms> getRoomById(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((event) => Rooms.fromSnap(event));
  }

  Future<List<Rooms>> getAllRooms() async {
    QuerySnapshot<Map<String, dynamic>> value =
        await _firestore.collection('rooms').get();
    List<Rooms> rooms = [];
    for (var room in value.docs) {
      rooms.add(Rooms.fromMap(room.data()));
    }
    return rooms;
  }

  void createCollab(Rooms collab) async {
    DocumentReference reference = _firestore.collection('Collabs').doc();
    collab.roomId = reference.id;
    await reference.set(collab.toJson());
  }

  Future<List<Rooms>> getAllCollabs(String uId) async {
    QuerySnapshot<Map<String, dynamic>> value = await FirebaseFirestore.instance
        .collection('Collabs')
        .where('members', arrayContainsAny: [uId])
        // .where('uid', isEqualTo: uId)
        .get();

    List<Rooms> collabs = [];
    for (var collab in value.docs) {
      collabs.add(Rooms.fromMap(collab.data()));
    }
    return collabs;
  }
}
