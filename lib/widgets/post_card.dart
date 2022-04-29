import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hyphen/Screens/canvas/mashup_canvas_screen.dart';
import 'package:hyphen/Screens/profile/profile_screen_new.dart';
import 'package:hyphen/model/users.dart' as model;
import 'package:hyphen/providers/room_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Screens/HomeScreen/comment_screen.dart';
import '../components/rounded_alert_box.dart';
import '../constants.dart';
import '../model/rooms.dart';
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';
import '../resources/rooms_methods.dart';
import '../utils/utils.dart';
import 'like_animation.dart';

class PostCard extends StatefulWidget {
  final snap;

  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  bool isPinClicked = false;
  final TextEditingController _roomName = TextEditingController();
  bool isLoading = false;
  late model.Users user;

  late RoomProvider roomProvider;

  void createRoom(String uid, String username) async {
    setState(() {
      isLoading = true;
    });
    try {

      Rooms? room = await RoomsMethods()
          .createRoom(_roomName.text, uid, username, [user.uid]);

      if (room == null) {
        showSnackbar(context, 'Room Already Exists!');
      } else {
        roomProvider.room = room;
      }

      if (roomProvider.room != null) {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MashupCanvasScreen(
                  image: widget.snap['postUrl'].toString(),
                )));
        showSnackbar(context, 'Room Created!');
      } else {
        showSnackbar(context, 'Error Creating Room');
      }
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
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackbar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackbar(
        context,
        err.toString(),
      );
    }
  }

  void pinPost() async {
    try {
      String res = await FireStoreMethods().pinPost(
        widget.snap['postUrl'].toString(),
        widget.snap['postId'].toString(),
        widget.snap['uid'],
        FirebaseAuth.instance.currentUser!.uid,
        widget.snap['username'],
        widget.snap['profImage'],
        DateFormat.yMMMd().format(widget.snap['datePublished'].toDate())
      );

      if (res != 'success') {
        showSnackbar(context, res);
      }
    } catch (err) {
      showSnackbar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 20,
              offset: const Offset(0, 10))
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
                  backgroundColor: kPrimaryColor,
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
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Profile2(uid: widget.snap['uid'].toString())));
                          },
                          child: Text(
                            widget.snap['username'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.snap['uid'].toString() == user.uid
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: [
                                      'Delete',
                                    ]
                                        .map(
                                          (e) => InkWell(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(e),
                                              ),
                                              onTap: () {
                                                deletePost(
                                                  widget.snap['postId']
                                                      .toString(),
                                                );
                                                // remove the dialog box
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      )
                    : Container(),
              ],
            ),
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              FireStoreMethods().likePost(
                widget.snap['postId'].toString(),
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
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
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Row(
            children: <Widget>[
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border,
                        ),
                  onPressed: () => FireStoreMethods().likePost(
                    widget.snap['postId'].toString(),
                    user.uid,
                    widget.snap['likes'],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.comment_outlined,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      postId: widget.snap['postId'].toString(),
                    ),
                  ),
                ),
              ),
              //mashup
              Visibility(
                visible: widget.snap['mashup'] == 1 ? false : true,
                child: IconButton(
                  onPressed: () {
                    RoundedAlertBox(
                      roomName: _roomName,
                      createRoom: () {
                        createRoom(
                          widget.snap['uid'],
                          widget.snap['username'],
                        );
                      },
                    ).openAlertBox(context);
                  },
                  icon: Image.asset('assets/images/mashup.png',
                      height: 30, width: 30),
                ),
              ),
              //pin
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('pins').where('postUrl', isEqualTo: widget.snap['postUrl'].toString()).snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if(snapshot.data == null){
                    return Center();
                  }
                  return snapshot.data!.docs.length == 1
                  ? 
                  IconButton(
                  icon: 
                      ImageIcon(
                          AssetImage("assets/images/pinred.png"),
                          color: Colors.pink,
                        ),
                  onPressed: () {
                    setState(() {
                      FireStoreMethods().deletePin(widget.snap['postUrl'].toString());
                      // isPinClicked = !isPinClicked;
                    });
                  })
                  : IconButton(
                    icon: ImageIcon(AssetImage("assets/images/pinoutline.png")),
                    onPressed: (){
                      setState(() {
                        pinPost();
                      });
                    },
                  );
                }
              ),
            ],
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyText2,
                    )),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(color: kPrimaryColor, fontSize: 16),
                      children: [
                        TextSpan(
                          text: widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '   ${widget.snap['description']}',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    child:Text(
                      'View all $commentLen comments',
                      style: const TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: widget.snap['postId'].toString(),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
