import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyphen/Screens/mashup/view_image.dart';
import 'package:hyphen/components/app_bar.dart';

import '../../constants.dart';
import '../../model/global.dart';
import '../../model/imagesList_model.dart';
import '../../providers/pixels_provider.dart';

class BackgroundImages extends StatefulWidget {
  const BackgroundImages({ Key? key }) : super(key: key);

  @override
  _BackgroundImagesState createState() => _BackgroundImagesState();
}

class _BackgroundImagesState extends State<BackgroundImages> {

  late FocusNode myFocusNode;
  TextEditingController searchController = new TextEditingController();
  PexelsProvider provider = new PexelsProvider();

  @override
  void initState() {
    super.initState();
    provider.getInitialWallpaper();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ScrollController _controller = ScrollController();

    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels >
            _controller.position.maxScrollExtent - 1000) {
          // You're at the top.
          provider.seartchNextPage();
        }
      }
    });

    return WillPopScope(
      onWillPop: () async{ return false; },
      child: Scaffold(
        backgroundColor: Color(0xffc9ced6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                icon: Icon(Icons.arrow_back, color: kPrimaryColor)
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
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _searchBar(),
                _crearCategorias(),
                _crearStreamListPhotos(size, _controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

    _searchBar(){
    return Container(
      child: Column(
            children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Container()),
                    _TextBox(
                focus: myFocusNode,
                estado: provider.getStateSearch(),
                controller: provider.getTextController()),
            IconButton(
              icon: Icon(Icons.search, size: 30),
              onPressed: () {
                setState(() {
                  // FocusScope.of(context).requestFocus(myFocusNode);
                  provider.setStateSearch();
                  provider.searchFromTextField();
                });
              },
            ),
                  ],
                ),
            ],
          ),
    );
  }

  _crearCategorias() {
    return Container(
      height: 40,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      width: double.infinity,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: provider.getTopics().length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Container(
              height: 70,
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Chip(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        topLeft: Radius.circular(12))),
                backgroundColor: Color(0xffdadadb),
                label: Text('${provider.getTopics()[index]}'),
              ),
            ),
            onTap: () {
              provider.searchFromCategory(provider.getTopics()[index]);
            },
          );
        },
      ),
    );
  }


  _crearStreamListPhotos(Size size, ScrollController _controller) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 1),
        child: StreamBuilder(
          stream: provider.photosStream,
          builder: (context, AsyncSnapshot<List<ImagesListModel>> snapshot) {
            if (snapshot.hasData) {
              if (provider.getLoading()) {
                return Center(child: CircularProgressIndicator());
              } else {
                final list = snapshot.data;
                return GridView.builder(
                  controller: _controller,
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.6,
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),
                  itemCount: list!.length,
                  itemBuilder: (context, i) {
                    return _PinterestItem(list[i], i);
                  },
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class _PinterestItem extends StatelessWidget {
  final ImagesListModel photo;
  final int i;
  _PinterestItem(this.photo, this.i);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Global.index = i;
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ViewImage()));
          },
          child: Hero(
            tag: '$i',
            child: Container(
              margin: EdgeInsets.only(top: 4, right: 2, left: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _createImage(),
              ),
            ),
          ),
        ),

      ],
    );
  }

  _createImage() {
    try {     
      return Stack(
        children: <Widget>[
        CachedNetworkImage(
          height: 400,
          width: 250,
          filterQuality: FilterQuality.high,
          imageUrl: photo.src!.portrait!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 500,
            color: Colors.white24,
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
              
        ]
      );
    } catch (e) {
      return Container(
        height: 50,
        width: 50,
        color: Colors.green,
      );
    }
  }
}


class _TextBox extends StatelessWidget {
  final bool? estado;
  final TextEditingController? controller;
  final FocusNode? focus;

  const _TextBox(
      {@required this.estado, @required this.controller, @required this.focus});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: AnimatedContainer(
          duration: Duration(milliseconds: 800),
          width: estado! ? size.width * 0.45 : 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black12,
            ),
            height: 40,
            width: 50,
            child: TextField(
              focusNode: focus,
              controller: controller,
              keyboardType: TextInputType.text,
              cursorColor: Colors.black,
              decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 5, bottom: 11, top: 11, right: 5),
                  hintText: "Search..."),
            ),
          )),
    );
  }
}