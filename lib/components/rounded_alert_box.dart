import 'package:flutter/material.dart';
import 'package:hyphen/model/rooms.dart';
import 'package:hyphen/providers/room_provider.dart';
import 'package:hyphen/resources/rooms_methods.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class RoundedAlertBox extends StatefulWidget {
  const RoundedAlertBox({
    Key? key,
    required this.roomName,
    required this.createRoom,
  }) : super(key: key);
  final TextEditingController roomName;
  final Function() createRoom;

  @override
  State<RoundedAlertBox> createState() => _RoundedAlertBoxState();

    openAlertBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: const EdgeInsets.only(top: 10.0),
            content: SizedBox(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text(
                        "Create Room",
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: TextField(
                      controller: roomName,
                      decoration: const InputDecoration(
                        hintText: "Room Name",
                        border: InputBorder.none,
                      ),
                      maxLines: 8,
                    ),
                  ),
                  InkWell(
                    onTap: createRoom,
                    child: Container(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: const Text(
                        "CREATE",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class _RoundedAlertBoxState extends State<RoundedAlertBox> {
  RoomProvider? roomProvider;

  List<Rooms> rooms = [];

  @override
  void initState() async {
    rooms = await RoomsMethods().getAllRooms();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    roomProvider = Provider.of<RoomProvider>(context);
    return widget.openAlertBox(context);
  }
}
