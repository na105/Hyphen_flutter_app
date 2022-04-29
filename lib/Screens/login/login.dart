import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyphen/constants.dart';

import '../login_register/login_form.dart';
import '../login_register/register_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool hidePassword = true;
  String occValue = '';
  Animation<double>? containerSize;
  AnimationController? animationController;
  Duration animationDuration = Duration(milliseconds: 270);
  final Duration initialDelay = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    animationController =
        AnimationController(vsync: this, duration: animationDuration);
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // used to determineif keyboard is opened or not
    double viewInset = MediaQuery.of(context).viewInsets.bottom;
    double defaultLoginSize = size.height - (size.height * 0.2);
    double defaultRegisterSize = size.height - (size.height * 0.1);

    containerSize =
        Tween<double>(begin: size.height * 0.1, end: defaultRegisterSize)
            .animate(CurvedAnimation(
                parent: animationController!, curve: Curves.linear));

    return Scaffold(
      body: Stack(
        children: [
          // Decorations
          Positioned(
              top: MediaQuery.of(context).size.width * 0.3,
              left: MediaQuery.of(context).size.width * 0.85,
              child: DelayedDisplay(
                delay: initialDelay,
                child: Container(
                  width: size.width * 0.33,
                  height: size.height * 0.19,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: kPrimaryColor),
                ),
              )),


          // Decorations
          Positioned(
              top: MediaQuery.of(context).size.width - 500,
              right: MediaQuery.of(context).size.width * 0.69,
              child: DelayedDisplay(
                delay: initialDelay,
                child: Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(250),
                      color: kPrimaryColor),
                ),
              )),


          // Cancel Button
          AnimatedOpacity(
            opacity: isLogin ? 0.0 : 1.0,
            duration: animationDuration,
            child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: size.width,
                  height: size.height * 0.1,
                  alignment: Alignment.bottomCenter,
                  child: IconButton(
                      onPressed: isLogin
                          ? null
                          : () {
                              //Returning null to disable the button
                              animationController!.reverse();
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                      icon: Icon(Icons.close),
                      color: kPrimaryColor),
                )),
          ),

          // Login form
          LoginForm(
            isLogin: isLogin,
            animationDuration: animationDuration,
            size: size,
            defaultLoginSize: defaultLoginSize,
          ),

          // Register container
          DelayedDisplay(
            delay: Duration(seconds: initialDelay.inSeconds + 4),
            child: AnimatedBuilder(
              animation: animationController!,
              builder: (context, child) {
                if (viewInset == 0 && isLogin) {
                  return buildRegisterContainer();
                } else if (!isLogin) {
                  return buildRegisterContainer();
                }

                // Returning empty container to hide the widget
                return Container();
              },
            ),
          ),

          // Register form
          DelayedDisplay(
              delay: initialDelay,
              child: RegisterForm(
                isLogin: isLogin,
                animationDuration: animationDuration,
                size: size,
                defaultLoginSize: defaultLoginSize,
                onChanged: (val) => setState(() => occValue = val),
              )),
        ],
      ),
    );
  }

  Widget buildRegisterContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: containerSize!.value + 10,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(100), topRight: Radius.circular(100)),
            color: kBackgroundColor),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: !isLogin
              ? null
              : () {
                  animationController!.forward();
                  setState(() {
                    isLogin = false;
                  });
                },
          child: isLogin
              ? Text(
                  'Don\'t have an account? Sign up',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
