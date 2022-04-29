import 'package:cloud_firestore/cloud_firestore.dart';

class Rooms {
  final String roomName;
  String roomId;
  final String uid;
  final String username;
  final List<String> members;
  String activeUser;
  String? image;
  String? roomAction;

  Rooms({
    required this.roomName,
    required this.roomId,
    required this.uid,
    required this.username,
    required this.members,
    required this.activeUser,
    this.image,
    this.roomAction,
  });

  static Rooms fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Rooms(
      roomName: snapshot['roomName'],
      roomId: snapshot['roomId'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      members: List.from(snapshot['members']),
      activeUser: snapshot['activeUser'],
      image: snapshot['image'],
      roomAction: snapshot['roomAction'],
    );
  }

  static Rooms fromMap(Map<String, dynamic> snapshot) {
    return Rooms(
      roomName: snapshot['roomName'],
      roomId: snapshot['roomId'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      members: List.from(snapshot['members']),
      activeUser: snapshot['activeUser'],
      image: snapshot['image'],
      roomAction: snapshot['roomAction'],
    );
  }

  Map<String, dynamic> toJson() => {
        'roomName': roomName,
        'roomId': roomId,
        'uid': uid,
        'username': username,
        'members': members,
        'activeUser': activeUser,
        'image': image,
        'roomAction': roomAction,
      };
}
