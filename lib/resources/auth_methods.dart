import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hyphen/model/users.dart' as model;

import '../utils/utils.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.Users> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.Users.fromSnap(documentSnapshot);
  }

  Future queryData(String queryString) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: queryString)
        .get();
  }

  // Signing up users
  Future<String> signUpUser({
    required String firstName,
    required String secondName,
    required String email,
    required String username,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty ||
          username.isNotEmpty ||
          firstName.isNotEmpty ||
          secondName.isNotEmpty) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        model.Users _user = model.Users(
            username: username,
            uid: cred.user!.uid,
            email: email,
            firstName: firstName,
            secondName: secondName,
            interests: [],
            followers: [],
            following: [],
            occupation: '',
            bio: '',
            photoUrl: '');

        //adding user in database
        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(_user.toJson());

        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          res = "Your email address is invalid, enter a valid email.";
          break;
        case "wrong-password":
          res = "Your password is wrong.";
          break;
        case "user-not-found":
          res = "User with this email doesn't exist.";
          break;
        case "username-conflict":
          res = "Username is taken, please change username.";
          break;
        case "email-already-in-use":
          res = "Email is already used, please change email address";
          break;
        default:
          res = "An undefined Error happened.";
      }
    }
    return res;
  }

  // logging in users
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //logging in user with email and password
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          res = "Your email address is invalid, enter a valid email.";
          break;
        case "wrong-password":
          res = "Your password is wrong.";
          break;
        case "user-not-found":
          res = "User with this email doesn't exist.";
          break;
        default:
          res = "An undefined Error happened.";
      }
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateEmailPassword(String oldPassword, String newpassword, BuildContext context) async {
    User user = await FirebaseAuth.instance.currentUser!;
    String? email = user.email;

    //Create field for user to input old password

    //pass the password here
    String password = oldPassword;
    String newPassword = newpassword;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email!,
          password: password,
      );
      
      user.updatePassword(newPassword).then((_){
        showSnackbar(context, "Successfully changed password");
      }).catchError((error){
        showSnackbar(context, "Password can't be changed" + error.toString());
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
      });
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackbar(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackbar(context, 'Wrong password provided for that user.');
      }
    }
  }
}
