import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';


import '../../constants.dart';
import '../../model/rooms.dart';
import '../../providers/room_provider.dart';
import '../../providers/user_provider.dart';
import '../../resources/rooms_methods.dart';
import '../../widgets/post_card.dart';
import 'mashup_card.dart';

class MashupScreen extends StatefulWidget {
  const MashupScreen({Key? key}) : super(key: key);

  @override
  State<MashupScreen> createState() => _MashupScreenState();
}

class _MashupScreenState extends State<MashupScreen> {

  late RoomProvider roomProvider;
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    userProvider = Provider.of<UserProvider>(context);
    roomProvider = Provider.of<RoomProvider>(context);

    return WillPopScope(
      onWillPop: () async{ return false; },
      child: Scaffold(
        backgroundColor:
            width > webScreenSize ? Colors.white : Colors.white,
        appBar: width > webScreenSize
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  leaveGroup();
                },
                icon: const Icon(Icons.arrow_back, color: kPrimaryColor)
              ),
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
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').orderBy('datePublished', descending: true).snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 10,
                ),
                child: MashupCard(
                  snap: snapshot.data!.docs[index].data(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void leaveGroup() {
    roomProvider.room.members.removeWhere(
          (element) {
        return element == userProvider.getUser.uid;
      },
    );

    uploadPostToFireStore(roomProvider.room);

    if (roomProvider.room.members.isEmpty) {
      RoomsMethods().deleteRoom(roomProvider.room);
    }
  }

  void uploadPostToFireStore(Rooms room) {
    RoomsMethods roomsMethods = RoomsMethods();
    roomsMethods.updateRoom(room);
  }
}