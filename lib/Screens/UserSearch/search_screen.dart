import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyphen/Screens/Profile/profile_screen_new.dart';
import 'package:hyphen/constants.dart';
import 'package:hyphen/resources/firestore_methods.dart';

import '../../model/users.dart';
import '../../responsive/mobile_screen_layou.dart';
import '../../responsive/responsive_layout_screen.dart';
import '../../responsive/web_screen_layout.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = new TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;

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
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ResponsiveLayout(webScreenLayout: WebScreenLayout(), mobileScreenLayout: MobileScreenLayout())));
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
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        alignment: Alignment.centerRight,
        color: Colors.transparent,
        child: Center(
            child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? MediaQuery.of(context).size.height/2 : MediaQuery.of(context).size.width/8,
            ),
          ],
        )));
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
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: 
                  (context) => Profile2(uid: user.uid)
                )
              ),
              child: ListTile(
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
