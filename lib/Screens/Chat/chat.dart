import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyphen/Screens/Chat/chatSearch.dart';
import 'package:hyphen/resources/helperFunctions.dart';

import '../../constants.dart';
import '../../resources/database.dart';
import 'chatRoom.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream? chatRooms;
  List<dynamic> users = [];
  String currentUserPhotoUrl = '';
  

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: (snapshot.data! as dynamic).docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  users = (snapshot.data! as dynamic).docs[index]['users'];
                  return ChatRoomsTile(
                    userName: (snapshot.data! as dynamic).docs[index]['chatRoomId']
                        .toString()
                        .replaceAll(Constants.myName, "")
                        .replaceAll("_", " "),
                    chatRoomId: (snapshot.data! as dynamic).docs[index]
                        ["chatRoomId"],
                    photoUrl: FirebaseAuth.instance.currentUser!.uid == (snapshot.data! as dynamic).docs[index]['senderUid'] ? 
                              (snapshot.data! as dynamic).docs[index]["currentUserphotoUrl"]
                              : (snapshot.data! as dynamic).docs[index]["photoUrl"],
                  );
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = (await HelperFunctions.getUserNameSharedPrefrence())!;
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${Constants.myName}");
      });
    });
    QuerySnapshot userInfoSnapshot = await DatabaseMethods().getUserInfoById(FirebaseAuth.instance.currentUser!.uid);
    currentUserPhotoUrl = userInfoSnapshot.docs[0]["photoUrl"];
    print(currentUserPhotoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: 110,
                      width: 130,
                      alignment: Alignment.centerRight,
                      color: Colors.transparent,
                      child: SvgPicture.asset('assets/images/logo.svg')),
                ],
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 12,
                            vertical: MediaQuery.of(context).size.height / 40),
                        child: Text(
                          'Chats',
                          style: GoogleFonts.staatliches(
                              fontSize: 60,
                              letterSpacing: 1,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3.8,
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatSearch()));
                        },
                        backgroundColor: kPrimaryColor,
                        splashColor: Colors.white.withOpacity(.5),
                        hoverColor: Colors.white,
                        child: Icon(
                          Icons.add,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                  chatRoomsList()
                ],
              ),
            ]))
          ],
        ),
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  final String photoUrl;

  ChatRoomsTile(
      {required this.userName,
      required this.chatRoomId,
      required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatRoom(
                      chatRoomId: chatRoomId, userName: userName,
                    )));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: CachedNetworkImageProvider(photoUrl),
                ),
                SizedBox(
                  width: 12,
                ),
                Text(userName,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(
              height: 15,
              thickness: 1,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
