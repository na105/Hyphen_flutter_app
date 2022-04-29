import 'package:flutter/material.dart';

import '../constants.dart';

class TemplatesContainers extends StatelessWidget {
  const TemplatesContainers({
    Key? key,
    required this.child,
    required this.text,
    required this.function
  }) : super(key: key);
  final Widget child;
  final String text;
  final Function() function;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8,),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            padding: EdgeInsets.symmetric(horizontal: 20,),
            width: MediaQuery.of(context).size.width * 2,
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                      color: kPrimaryColor.withOpacity(0.6),
                      spreadRadius: 4,
                      blurRadius: 20,
                      offset: Offset(0, 10))
                ],
                color: Colors.white.withOpacity(0.8)),
          ),
          InkWell(
            onTap: function,
            child: Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.symmetric(vertical: 50, horizontal: 25),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor),
                textAlign: TextAlign.center
              ),
            ),
          )
        ],
      ),
    );
  }
}
