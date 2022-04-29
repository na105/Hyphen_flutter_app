import 'package:flutter/material.dart';
import 'package:hyphen/constants.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    Key? key,
    required this.child,
    required this.onTap
  }) : super(key: key);

  final Widget child;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width:size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: kPrimaryColor
        ),

        padding: EdgeInsets.symmetric(vertical:20),
        alignment: Alignment.center,
        child: child
      ),
    );
  }
}

