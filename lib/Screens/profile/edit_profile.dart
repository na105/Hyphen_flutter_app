import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hyphen/components/rounded_button.dart';
import 'package:hyphen/components/rounded_input.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/input_container.dart';
import '../../constants.dart';
import '../../utils/utils.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Uint8List? _image;
  bool _isLoading = false;
  String? picUrl;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  selectImage() async {
    Uint8List im = await pickImage(
      ImageSource.gallery,
    );
    setState(() {
      if (im != null) {
        _image = im;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          extendBodyBehindAppBar: false,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: kPrimaryColor))),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: kPrimaryColor,
                    ),
                  ),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index].data();
                    firstNameController.text = doc['firstName'];
                    secondNameController.text = doc['secondName'];
                    usernameController.text = doc['username'];
                    bioController.text = doc['bio'];
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              'Edit profile',
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Stack(
                            children: [
                              _image != null
                                  ? CircleAvatar(
                                      radius: 64,
                                      backgroundImage: MemoryImage(_image!),
                                      backgroundColor: Colors.white,
                                    )
                                  : CircleAvatar(
                                      radius: 64,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              doc['photoUrl']),
                                      backgroundColor: Colors.white,
                                    ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 1, color: Colors.black),
                                      color: Colors.white,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: selectImage,
                                    ),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          RoundedInput(
                            icon: Icons.face_sharp,
                            hint: 'First Name',
                            controller: firstNameController,
                            type: TextInputType.name,
                            function: (value) {
                              // name must be at least 3 characters
                              if (value!.isEmpty) {
                                return ("First Name cannot be Empty");
                              }
                              //base case
                              return null;
                            },
                            action: TextInputAction.next,
                          ),
                          RoundedInput(
                            icon: Icons.face_sharp,
                            hint: 'Second Name',
                            controller: secondNameController,
                            type: TextInputType.name,
                            function: (value) {
                              if (value!.isEmpty) {
                                return ("Second Name cannot be Empty");
                              }
                              // base case
                              return null;
                            },
                            action: TextInputAction.next,
                          ),
                          RoundedInput(
                            icon: Icons.account_circle,
                            hint: 'Username',
                            controller: usernameController,
                            type: TextInputType.text,
                            function: (value) {
                              if (value!.isEmpty) {
                                return ("Username field cannot be empty");
                              }
                              // reg expression for username validation
                              RegExp regex = RegExp(r'^.{3,}$');
                              if (!regex.hasMatch(value)) {
                                return ("Enter a valid username with a minimum of 3 characters");
                              }
                              // base case
                              return null;
                            },
                            action: TextInputAction.next,
                          ),
                          InputContainer(
                              child: TextFormField(
                            cursorColor: kPrimaryColor,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.text_snippet_outlined,
                                    color: kPrimaryColor),
                                hintText: "Bio",
                                labelText: 'Bio',
                                border: InputBorder.none),
                            keyboardType: TextInputType.text,
                            controller: bioController,
                          )),
                          RoundedButton(
                              child: !_isLoading
                                  ? const Text('Update',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18))
                                  : const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 5,
                                    ),
                              onTap: () async {
                                _isLoading = true;
                                if (_image != null) {
                                  Reference ref = FirebaseStorage.instance
                                      .ref()
                                      .child('profilePics')
                                      .child(FirebaseAuth
                                          .instance.currentUser!.uid);
                                  await FirebaseStorage.instance
                                      .refFromURL(doc['photoUrl'])
                                      .delete();
                                  UploadTask uploadTask =
                                      ref.putData(_image!);
                                  TaskSnapshot snap = await uploadTask;
                                  picUrl = await snap.ref.getDownloadURL();
                                  snapshot.data!.docs[index].reference
                                      .update({
                                    'firstName': firstNameController.text,
                                    'secondName': secondNameController.text,
                                    'username': usernameController.text,
                                    'photoUrl': picUrl,
                                    'bio': bioController.text,
                                  }).whenComplete(
                                          () => Navigator.pop(context));
                                } else {
                                  String picUrl = await FirebaseStorage
                                      .instance
                                      .refFromURL(doc['photoUrl'])
                                      .getDownloadURL();
                                  snapshot.data!.docs[index].reference
                                      .update({
                                    'firstName': firstNameController.text,
                                    'secondName': secondNameController.text,
                                    'username': usernameController.text,
                                    'photoUrl': picUrl,
                                    'bio': bioController.text,
                                  }).whenComplete(
                                          () => Navigator.pop(context));
                                }
                              })
                        ]);
                  });
            },
          ),
        ));
  }
}
