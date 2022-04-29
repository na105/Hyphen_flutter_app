import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hyphen/Screens/Chat/chatRoom.dart';
import 'package:hyphen/constants.dart';
import 'package:hyphen/resources/database.dart';
import 'package:hyphen/resources/firestore_methods.dart';

import '../../model/users.dart';

class ChatSearch extends StatefulWidget {
  const ChatSearch({Key? key}) : super(key: key);

  @override
  _ChatSearchState createState() => _ChatSearchState();
}

class _ChatSearchState extends State<ChatSearch> {
  final TextEditingController searchController = new TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;

  @override
  void initState() {
    super.initState();
  }

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where('username', isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_sharp,
            size: 30,
            color: kPrimaryColor,
          )),
      title: Container(
        decoration: BoxDecoration(
          color: kPrimaryColor.withAlpha(50),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
              hintText: 'Search usernames...',
              border: InputBorder.none,
              filled: true,
              prefixIcon: Icon(Icons.account_box, size: 28),
              suffixIcon:
                  IconButton(onPressed: clearSearch, icon: Icon(Icons.clear))),
          onFieldSubmitted: handleSearch,
        ),
      ),
    );
  }

  Container buildNoContent() {
    return Container();
  }

  buildSearchResults() {
    return FutureBuilder(
        future: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<UserResult> searchResults = [];
          (snapshot.data! as dynamic).docs.forEach((doc) {
            Users user = Users.fromSnap(doc);
            UserResult searchResult = UserResult(user);
            searchResults.add(searchResult);
          });
          return ListView(
            children: searchResults,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}

class UserResult extends StatelessWidget {
  final Users user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor.withAlpha(50),
      child: Visibility(
        visible:
            user.uid == FirebaseAuth.instance.currentUser!.uid ? false : true,
        child: Column(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.username,
                style: TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${user.firstName} ${user.secondName}',
                style: TextStyle(color: kPrimaryColor),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    List<String> users = [
                      Constants.myName,
                      user.username.toString()
                    ];

                    String chatRoomId = getChatRoomId(
                        Constants.myName, user.username.toString());

                    String photoUrl = user.photoUrl;
                    String receiverUid = user.uid;

                    QuerySnapshot userInfoSnapshot = await DatabaseMethods().getUserInfoById(FirebaseAuth.instance.currentUser!.uid);
                    String currentUserPhotoUrl = userInfoSnapshot.docs[0]["photoUrl"];
                    String senderUid = FirebaseAuth.instance.currentUser!.uid;

                    DatabaseMethods().sendMesage(users, chatRoomId, photoUrl, currentUserPhotoUrl, senderUid, receiverUid);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatRoom(
                                  chatRoomId: chatRoomId, userName: user.username, 
                                )));
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 6),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(24)),
                    child: Text(
                      "Message",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 2.0,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
