import 'package:cloud_firestore/cloud_firestore.dart';

class Users{
  final String email;
  final String username;
  final String uid;
  final String firstName;
  final String secondName;
  final String bio;
  final String photoUrl;
  final String occupation;
  final List interests;
  final List followers;
  final List following;

  const Users({
    required this.email,
    required this.username,
    required this.uid,
    required this.firstName,
    required this.secondName,
    required this.bio,
    required this.photoUrl,
    required this.occupation,
    required this.interests,
    required this.followers,
    required this.following,
  });

  static Users fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String, dynamic>;

    return Users(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      firstName: snapshot['firstName'],
      secondName: snapshot['secondName'],
      bio: snapshot['bio'],
      photoUrl: snapshot['photoUrl'],
      occupation: snapshot['occupation'],
      interests: snapshot['intrests'],
      following: snapshot['following'],
      followers: snapshot['followers'],
    );
  }

  Map<String, dynamic> toJson() =>{
    'username': username,
    'uid': uid,
    'email': email,
    'firstName': firstName,
    'secondName': secondName,
    'bio': bio,
    'photoUrl': photoUrl,
    'occupation':occupation,
    'intrests': interests,
    'followers': followers,
    'following': following,
  };
}