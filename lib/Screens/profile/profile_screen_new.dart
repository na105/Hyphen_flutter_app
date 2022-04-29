import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hyphen/Screens/UserSearch/search_screen.dart';
import 'package:hyphen/Screens/login/login.dart';
import 'package:hyphen/Screens/profile/changePassword.dart';
import 'package:hyphen/constants.dart';
import 'package:hyphen/resources/auth_methods.dart';
import 'package:hyphen/resources/firestore_methods.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../model/rooms.dart';
import '../../resources/rooms_methods.dart';
import '../../utils/utils.dart';
import 'edit_profile.dart';

class Profile2 extends StatefulWidget {
  final String uid;

  const Profile2({Key? key, required this.uid}) : super(key: key);

  @override
  _Profile2State createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  final PanelController _panelController = PanelController();
  bool _isOpen = false;
  String state = "feed";
  bool isOpened = false;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  bool isMenuOpen = false;

  toggleMenu([bool end = true]) {
    if (end) {
      final _state = _sideMenuKey.currentState!;
      if (_state.isOpened) {
        _state.closeSideMenu();
      } else {
        _state.openSideMenu();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackbar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SideMenu(
            key: _sideMenuKey,
            inverse: true,
            menu: buildMenu(),
            background: kPrimaryColor,
            type: SideMenuType.slide,
            onChange: (_isOpened) {
              setState(() {
                isOpened = _isOpened;
              });
            },
            child: Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  automaticallyImplyLeading: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Visibility(
                      visible:
                          FirebaseAuth.instance.currentUser!.uid == widget.uid
                              ? false
                              : true,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_sharp,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop(MaterialPageRoute(
                              builder: (context) => const SearchScreen()));
                        },
                      )),
                ),
                body: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.7,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    userData['photoUrl']),
                                fit: BoxFit.cover)),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 0.3,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),

                    //Sliding Panel
                    SlidingUpPanel(
                      controller: _panelController,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(32),
                          topLeft: Radius.circular(32)),
                      minHeight: MediaQuery.of(context).size.height * 0.3,
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                      body: GestureDetector(
                          onTap: () => _panelController.close(),
                          child: Container(color: Colors.transparent)),
                      panelBuilder: (ScrollController controller) {
                        return _panelBody(controller);
                      },
                      onPanelSlide: (value) {
                        if (value >= 0.2) {
                          if (!_isOpen) {
                            setState(() {
                              _isOpen = true;
                            });
                          }
                        }
                      },
                      onPanelClosed: () {
                        setState(() {
                          _isOpen = false;
                        });
                      },
                    ),
                  ],
                )),
          );
  }

  // Panel Body
  SingleChildScrollView _panelBody(ScrollController controller) {
    double hPadding = 40;

    return SingleChildScrollView(
      controller: controller,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            height: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Visibility(
                  visible: _isOpen ? true : false,
                  child: IconButton(
                      onPressed: () => _panelController.close(),
                      icon: const Icon(Icons.arrow_drop_up_sharp,
                          size: 50, color: kPrimaryColor)),
                ),
                _titleSection(),
                _infoSection(),
                _actionSection(),
                const SizedBox(height: 15),
              ],
            ),
          ),
          buildTogglePost(),
          _buildProfilePosts(),
        ],
      ),
    );
  }

  Widget _buildProfilePosts() {
    if (state == 'feed') {
      return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('posts')
              .where('uid', isEqualTo: widget.uid)
              .get(),
          builder: (context, snapshot) {
            // if (snapshot.hasError) {
            //   return Container();
            // }
            if (snapshot.hasData) {
              return StaggeredGridView.countBuilder(
                crossAxisCount: 3,
                shrinkWrap: true,
                primary: false,
                itemCount: (snapshot.data! as dynamic).docs.length,
                itemBuilder: (context, index) => Image.network(
                  (snapshot.data! as dynamic).docs[index]['postUrl'],
                  fit: BoxFit.cover,
                ),
                staggeredTileBuilder: (index) =>
                    MediaQuery.of(context).size.width > webScreenSize
                        ? StaggeredTile.count(
                            (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
                        : StaggeredTile.count(
                            (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
    } else if (state == 'collabs') {
      return FutureBuilder<List<Rooms>>(
          future: RoomsMethods().getAllCollabs(widget.uid),
          builder: (context, projectSnap) {
            if (projectSnap.hasData) {
              return StaggeredGridView.countBuilder(
                crossAxisCount: 3,
                shrinkWrap: true,
                primary: false,
                itemCount: projectSnap.data?.length,
                itemBuilder: (context, index) {
                  return Image.memory(
                      stringToUInt8(projectSnap.data?[index].image));
                },
                staggeredTileBuilder: (index) =>
                    MediaQuery.of(context).size.width > webScreenSize
                        ? StaggeredTile.count(
                            (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
                        : StaggeredTile.count(
                            (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          });
    } else if (state == 'pins') {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('pins')
              .snapshots(),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const Center(
            //     child: CircularProgressIndicator(),
            //   );
            // }
            return StaggeredGridView.countBuilder(
              crossAxisCount: 3,
              shrinkWrap: true,
              primary: false,
              itemCount: (snapshot.data! as dynamic).docs.length == 0
                  ? 0
                  : (snapshot.data! as dynamic).docs.length,
              itemBuilder: (context, index) => Image.network(
                (snapshot.data! as dynamic).docs[index]['postUrl'],
                fit: BoxFit.cover,
              ),
              staggeredTileBuilder: (index) =>
                  MediaQuery.of(context).size.width > webScreenSize
                      ? StaggeredTile.count(
                          (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
                      : StaggeredTile.count(
                          (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            );
          });
    }
    return Container();
  }

  Uint8List stringToUInt8(String? signature) {
    return Uint8List.fromList(signature!.codeUnits);
  }

  getState(String state) {
    setState(() {
      this.state = state;
    });
  }

  buildTogglePost() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            color: state == 'feed' ? Colors.grey.shade200 : Colors.white,
            alignment: state == 'feed' ? Alignment.center : null,
            padding: state == 'feed'
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 6)
                : null,
            child: TextButton(
              onPressed: () => getState('feed'),
              child: const Text('Feed'),
            ),
          ),
          Container(
            color: state == 'collabs' ? Colors.grey.shade200 : Colors.white,
            alignment: state == 'collabs' ? Alignment.center : null,
            padding: state == 'collabs'
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 6)
                : null,
            child: TextButton(
              onPressed: () => getState('collabs'),
              child: const Text('Collabs'),
            ),
          ),
          Visibility(
            visible: FirebaseAuth.instance.currentUser!.uid == widget.uid
                ? true
                : false,
            child: Container(
              color: state == 'pins' ? Colors.grey.shade200 : Colors.white,
              alignment: state == 'pins' ? Alignment.center : null,
              padding: state == 'pins'
                  ? EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 6)
                  : null,
              child: TextButton(
                onPressed: () => getState('pins'),
                child: const Text('Pins'),
              ),
            ),
          ),
        ]);
  }

  // Action Section
  Row _actionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Visibility(
          visible: !_isOpen,
          child: Expanded(
            child: OutlinedButton(
              onPressed: () => _panelController.open(),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: kPrimaryColor))),
              ),
              child: const Text(
                'VIEW PROFILE',
                style: TextStyle(
                    fontFamily: 'NimbusSanL',
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        Visibility(
          visible: !_isOpen,
          child: const SizedBox(
            width: 20,
          ),
        ),
        Visibility(
          visible: FirebaseAuth.instance.currentUser!.uid == widget.uid
              ? true
              : false,
          child: Expanded(
            child: ElevatedButton(
                onPressed: () => toggleMenu(),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0))),
                ),
                child: const Text('SETTINGS',
                    style: TextStyle(
                        fontFamily: 'NimbusSanL',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white))),
          ),
        ),
        Visibility(
          visible: FirebaseAuth.instance.currentUser!.uid == widget.uid
              ? false
              : isFollowing
                  ? false
                  : true,
          child: Expanded(
            child: ElevatedButton(
                onPressed: () async {
                  await FireStoreMethods().followUser(
                      FirebaseAuth.instance.currentUser!.uid, userData['uid']);
                  setState(() {
                    isFollowing = true;
                    followers++;
                  });
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0))),
                ),
                child: const Text('FOLLOW',
                    style: TextStyle(
                        fontFamily: 'NimbusSanL',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white))),
          ),
        ),
        Visibility(
          visible: FirebaseAuth.instance.currentUser!.uid == widget.uid
              ? false
              : isFollowing
                  ? true
                  : false,
          child: Expanded(
            child: ElevatedButton(
                onPressed: () async {
                  await FireStoreMethods().followUser(
                      FirebaseAuth.instance.currentUser!.uid, userData['uid']);
                  setState(() {
                    isFollowing = false;
                    followers--;
                  });
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0))),
                ),
                child: const Text('UNFOLLOW',
                    style: TextStyle(
                        fontFamily: 'NimbusSanL',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white))),
          ),
        ),
      ],
    );
  }

  Widget buildMenu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Settings',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                    color: Colors.white)),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EditProfile()));
            },
            leading: const Icon(Icons.person, size: 25.0, color: Colors.white),
            title: const Text("Edit Profile",
                style: TextStyle(fontSize: 18, fontFamily: 'OpenSans')),
            textColor: Colors.white,
            dense: true,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ChangePassword()));
            },
            leading:
                const Icon(Icons.password, size: 25.0, color: Colors.white),
            title: const Text("Change Password",
                style: TextStyle(fontSize: 18, fontFamily: 'OpenSans')),
            textColor: Colors.white,
            dense: true,

            // padding: EdgeInsets.zero,
          ),
          ListTile(
            onTap: () {
              showGeneralDialog(
                context: context,
                barrierColor: Colors.black38,
                barrierLabel: 'Label',
                barrierDismissible: true,
                pageBuilder: (_, __, ___) => Center(
                  child: Container(
                    margin: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.08),
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height / 2.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: kPrimaryColor, spreadRadius: 4),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.04),
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.03,
                            left: MediaQuery.of(context).size.width * 0.04,
                            right: MediaQuery.of(context).size.height * 0.04),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                'Are you sure you want to delete your account?',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 25),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 40,
                            ),
                            Center(
                              child: Text(
                                "All of your posts and data will be permenantly deleted",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 20,
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() async {
                                        FireStoreMethods().deleteUser();
                                        try {
                                          await FirebaseAuth
                                              .instance.currentUser!
                                              .delete();
                                        } on FirebaseAuthException catch (e) {
                                          if (e.code ==
                                              'requires-recent-login') {
                                            print(
                                                'The user must reauthenticate before this operation can be executed.');
                                          }
                                        }
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      });
                                    },
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.21,
                                        child: Center(
                                          child: Text("Yes",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                        ))),
                                SizedBox(
                                  width: 15,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.21,
                                        child: Center(
                                          child: Text("No",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                        )))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            leading: const Icon(Icons.person_off_sharp,
                size: 25.0, color: Colors.white),
            title: const Text("Delete Account",
                style: TextStyle(fontSize: 18, fontFamily: 'OpenSans')),
            textColor: Colors.white,
            dense: true,
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 4.5),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextButton(
                onPressed: () async {
                  await AuthMethods().signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Sign Out',
                    style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 2.2,
                        fontFamily: 'OpenSans',
                        color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Info Section
  Row _infoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _infoCell(title: 'Followers', value: followers.toString()),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey,
        ),
        _infoCell(title: 'Following', value: following.toString()),
        Container(
          width: 1,
          height: 40,
          color: Colors.grey,
        ),
        _infoCell(title: 'Bio', value: userData['bio'])
      ],
    );
  }

  // Info Cell
  Column _infoCell({required String title, required String value}) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w300,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ))
      ],
    );
  }

  // Title Section
  Column _titleSection() {
    return Column(
      children: <Widget>[
        Text(
          '${userData['firstName']} ${userData['secondName']}',
          style: const TextStyle(
            fontFamily: 'Oswald-Medium',
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          '@${userData['username']}',
          style: const TextStyle(
            fontFamily: 'Oswald-Medium',
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
