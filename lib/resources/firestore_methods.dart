import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../model/post.dart';
import 'storage_methods.dart';
import '../utils/api_service.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // adding user's details
  Future<String> addUserDetails(
      String bio, Uint8List file, String occupation, List intrests) async {
    String res = 'Some error occurred';
    try {
      Map<String, dynamic> map = Map();
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('profilePics', file, false);

      if (file != null) {
        map['photoUrl'] = photoUrl;
      }
      map['bio'] = bio;
      map['occupation'] = occupation;
      map['intrests'] = intrests;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(map);

      res = 'success';
    } catch (e) {
      e.toString();
      res = e.toString();
    }
    return res;
  }

  int allowImg = 0;
  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage, int mashup) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      await ApiService.getData(photoUrl).then((value) {
        if (value.gore.prob >= 0.5 || value.nudity.safe <= 0.5 || value.text.profanity.isNotEmpty || value.text.social.isNotEmpty) {
          allowImg = 1;
        }
      });
      if (allowImg == 1) {
        res = "Image is not under moderation limits";
        return res;
      }
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        mashup: mashup,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Pin Post
  Future<String> pinPost(
      String postUrl,
      String postId,
      String uid,
      String currentUserId,
      String name,
      String profilePic,
      String datePublished) async {
    String res = "Some error occurred";
    try {
      String pinId = const Uuid().v1();

      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('pins')
          .doc(pinId)
          .set({
        'profilePic': profilePic,
        'postId': postId,
        'name': name,
        'uid': uid,
        'currentUserId': currentUserId,
        'pinId': pinId,
        'postUrl': postUrl,
        'datePublished': datePublished,
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePin(String postUrl) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('pins')
          .where('postUrl', isEqualTo: postUrl)
          .get()
          .then((snapshot) {
        snapshot.docs[0].reference.delete();
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> deleteUser() async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).delete();
      await _firestore
          .collection('posts')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((element) {
          element.reference.delete();
        });
      });
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection("pins")
          .where('currentUserId', isEqualTo: _auth.currentUser!.uid)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((element) {
          element.reference.delete();
        });
      });
      await FirebaseAuth.instance.signOut();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
