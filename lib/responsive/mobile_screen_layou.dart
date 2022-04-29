import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../Screens/AddPost/add_post_screen.dart';
import '../Screens/Chat/chat.dart';
import '../Screens/HomeScreen/home_screen.dart';
import '../Screens/UserSearch/search_screen.dart';
import '../Screens/mashup/create_room_screen.dart';
import '../Screens/profile/profile_screen_new.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _currentIndex = 0;

  // VERY IMP TO PUT YOUR SCREENS IN THIS LIST (MISSING: SEARCH, AND MASHUP)
  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(),
    const AddPostScreen(),
    const CreateRoomScreen(),
    Profile2(uid: FirebaseAuth.instance.currentUser!.uid)
  ];
  PageController _pageController = PageController(); // for tabs animation

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: _screens,
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
            )
          ],
          color: Colors.grey.withOpacity(0.2),
          // borderRadius: BorderRadius.circular(15),
        ),
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() {
              _currentIndex = i;
              _pageController.jumpToPage(_currentIndex);
            });
          },
          items: [
            /// Home
            SalomonBottomBarItem(
              icon: const Icon(Icons.home, size: 30, color: Color(0xFF182F50)),
              title: const Text("Home",
                  style: TextStyle(fontSize: 13, color: Color(0xFF182F50))),
              selectedColor: Colors.black87,
            ),

            /// Search
            SalomonBottomBarItem(
              icon:  ImageIcon(AssetImage('assets/images/chat.png'), size: 30,),
              title: const Text("Chat",
                  style: TextStyle(fontSize: 13, color: Color(0xFF182F50))),
              selectedColor: Colors.black87,
            ),

            /// Post/Create
            SalomonBottomBarItem(
              icon: const Icon(Icons.add, size: 30, color: Color(0xFF182F50)),
              title: const Text("Add",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF182F50))),
              selectedColor: Colors.black87,
            ),

            /// Mashup
            SalomonBottomBarItem(
              icon: Image.asset('assets/images/mashup.png',
                  height: 30, width: 30),
              title: const Text("Mashup",
                  style: TextStyle(fontSize: 13, color: Color(0xFF182F50))),
              selectedColor: Colors.black87,
            ),

            /// Profile
            SalomonBottomBarItem(
              icon:
                  const Icon(Icons.person, size: 30, color: Color(0xFF182F50)),
              title: const Text("Profile",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF182F50))),
              selectedColor: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
