import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../../constants.dart';
import '../../widgets/post_card.dart';
import '../UserSearch/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async{ return false; },
      child: Scaffold(
        backgroundColor:
            width > webScreenSize ? Colors.white : Colors.white,
        appBar: width > webScreenSize
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                centerTitle: false,
                leading: 
                IconButton(
                  onPressed: (){
                    setState(() {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchScreen()));
                    });
                  }, 
                  icon: Icon(Icons.search_sharp, size: 30, color: kPrimaryColor,)
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
                child: CircularProgressIndicator(backgroundColor: Colors.white,),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 10,
                ),
                child: PostCard(
                  snap: snapshot.data!.docs[index].data(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}