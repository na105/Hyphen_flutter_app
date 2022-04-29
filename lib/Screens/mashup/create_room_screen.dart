import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyphen/components/rounded_alert_box.dart';
import 'package:hyphen/components/update_alert_box.dart';
import 'package:hyphen/model/users.dart';
import 'package:hyphen/providers/room_provider.dart';
import 'package:hyphen/resources/rooms_methods.dart';
import 'package:hyphen/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar.dart';
import '../../constants.dart';
import '../../model/rooms.dart';
import '../../providers/user_provider.dart';
import 'create_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _roomName = TextEditingController();
  late UserProvider? userProvider;
  bool isLoading = false;
  late RoomProvider roomProvider;
  late Users user;

  void createRoom(String uid, String username) async {
    setState(() {
      isLoading = true;
    });
    try {
      user = userProvider!.getUser;

      Rooms? room = await RoomsMethods()
          .createRoom(_roomName.text, uid, username, [user.uid]);

      if (room == null) {
        showSnackbar(context, 'Room Already Exists!');
        Navigator.of(context).pop();
        return;
      } else {
        roomProvider.room = room;
      }

      setState(() {
        isLoading = false;
      });

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const CreateScreen()));

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackbar(context, e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _roomName.dispose();
  }

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
          const appBar(),
          SliverList(
              delegate: SliverChildListDelegate([
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      'Create your Art',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
                    ),
                    Container(
                        height: 310,
                        width: 230,
                        alignment: Alignment.centerRight,
                        color: Colors.transparent,
                        child: SvgPicture.asset('assets/images/draw.svg')),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              UpdateAlertBox().joinRoomAlertBox(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              width: MediaQuery.of(context).size.width * 0.37,
                              height: MediaQuery.of(context).size.height * 0.22,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: kPrimaryColor.withAlpha(50)),
                              child: Column(
                                children: const [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  RotatedBox(
                                      quarterTurns: 1,
                                      child: Icon(Icons.ios_share_sharp,
                                          size: 34)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Join a Room',
                                    style: TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          InkWell(
                            onTap: () {
                              RoundedAlertBox(
                                roomName: _roomName,
                                createRoom: () {
                                  createRoom(userProvider!.getUser.uid,
                                      userProvider!.getUser.username);
                                },
                              ).openAlertBox(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              width: MediaQuery.of(context).size.width * 0.37,
                              height: MediaQuery.of(context).size.height * 0.22,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: kPrimaryColor.withAlpha(50)),
                              child: Column(
                                children: const [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Icon(Icons.add_circle_outline_sharp,
                                      size: 34),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Create a Room',
                                    style: TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ])),
        ],
      )),
    );
  }
}
