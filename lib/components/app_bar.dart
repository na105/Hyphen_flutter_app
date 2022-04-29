import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class appBar extends StatelessWidget {
  const appBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
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
    );
  }
}
