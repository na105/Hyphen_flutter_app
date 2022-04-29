import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyphen/Screens/mashup/view_mashup_image_screen.dart';
import 'package:hyphen/model/users.dart' as model;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../providers/user_provider.dart';
import '../../resources/firestore_methods.dart';
import '../../utils/utils.dart';
import '../../widgets/like_animation.dart';

class MashupCard extends StatefulWidget {
  final snap;
  const MashupCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<MashupCard> createState() => _MashupCardState();
}

class _MashupCardState extends State<MashupCard> {
  @override
  Widget build(BuildContext context) {
    final model.Users user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return widget.snap['mashup'] == 0
        ? InkWell(
          onTap: (){
            setState(() {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewMashupImageScreen(url: widget.snap['postUrl'].toString())));
            });
          },
          child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.3,
                  // boundary needed for web
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 20,
                          offset: Offset(0, 10))
                    ],
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // HEADER SECTION OF THE POST
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ).copyWith(right: 0),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(
                                widget.snap['profImage'].toString(),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.snap['username'].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // IMAGE SECTION OF THE POST
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: double.infinity * 0.8,
                            child: Image.network(
                              widget.snap['postUrl'].toString(),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
        )
        : Container();
  }
}
