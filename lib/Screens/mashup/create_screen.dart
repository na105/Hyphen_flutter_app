import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyphen/Screens/canvas/blank_canvas_screen.dart';
import 'package:hyphen/Screens/mashup/background_images.dart';
import 'package:hyphen/Screens/mashup/mashup_screen.dart';
import 'package:provider/provider.dart';

import '../../components/templates_containers.dart';
import '../../constants.dart';
import '../../model/rooms.dart';
import '../../providers/room_provider.dart';
import '../../providers/user_provider.dart';
import '../../resources/rooms_methods.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  late RoomProvider roomProvider;
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    roomProvider = Provider.of<RoomProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                  onPressed: () {
                    leaveGroup();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: kPrimaryColor)),
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
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 15),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        child: const Text(
                          'Templates',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 38),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TemplatesContainers(
                        child: Container(),
                        text: 'Blank Canvas',
                        function: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const BlankCanvas()));
                        },
                      ),
                      TemplatesContainers(
                        child: Container(),
                        text: 'Mashup',
                        function: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MashupScreen()));
                        },
                      ),
                      TemplatesContainers(
                        child: Container(),
                        text: 'Background Images',
                        function: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const BackgroundImages()));
                        },
                      ),
                    ],
                  ),
                ),
              )
            ]))
          ],
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
