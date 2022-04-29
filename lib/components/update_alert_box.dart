import 'package:flutter/material.dart';
import 'package:hyphen/Screens/canvas/mashup_canvas_screen.dart';
import 'package:hyphen/model/rooms.dart';
import 'package:hyphen/providers/room_provider.dart';
import 'package:hyphen/providers/user_provider.dart';
import 'package:hyphen/resources/rooms_methods.dart';
import 'package:provider/provider.dart';

class UpdateAlertBox extends StatelessWidget {
  UpdateAlertBox({
    Key? key,
  }) : super(key: key);

  RoomProvider? roomProvider;
  UserProvider? userProvider;

  @override
  Widget build(BuildContext context) {
    return joinRoomAlertBox(context);
  }

  joinRoomAlertBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext c) {
          roomProvider = Provider.of<RoomProvider>(context);
          userProvider = Provider.of<UserProvider>(context);

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
                        "Join Room",
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
                  FutureBuilder<List<Rooms>>(
                    future: RoomsMethods().getAllRooms(),
                    builder: (context, projectSnap) {
                      if (projectSnap.connectionState == ConnectionState.none) {
                        return const Text('No Rooms Created Yet!');
                      }
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                            itemCount: projectSnap.data?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  roomProvider?.room = projectSnap.data![index];
                                  int? length =
                                      roomProvider?.room.members.length;

                                  if (length! < 4) {
                                    roomProvider?.room.members
                                        .add('${userProvider?.getUser.uid}');
                                    RoomsMethods()
                                        .updateRoom(projectSnap.data![index]);
                                    Navigator.pop(context);

                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                              const  MashupCanvasScreen(
                                                    image: '')));
                                  } else {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Room Full')));
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 20,
                                          offset: const Offset(0, 10))
                                    ],
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          projectSnap.data![index].roomName,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        ),
                                        Text(
                                            '${projectSnap.data![index].members.length} Members'),
                                      ]),
                                ),
                              );
                            }),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
