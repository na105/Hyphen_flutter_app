import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:hyphen/components/rounded_button.dart';
import 'package:hyphen/components/rounded_input.dart';
import 'package:hyphen/components/rounded_password_input.dart';
import 'package:hyphen/constants.dart';
import 'package:hyphen/resources/auth_methods.dart';
import 'package:hyphen/resources/helperFunctions.dart';
import 'package:hyphen/responsive/mobile_screen_layou.dart';
import 'package:hyphen/responsive/responsive_layout_screen.dart';
import 'package:hyphen/responsive/web_screen_layout.dart';
import 'package:hyphen/utils/utils.dart';

import '../../resources/database.dart';
import '../login/forgotpassword_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm(
      {Key? key,
      required this.isLogin,
      required this.animationDuration,
      required this.size,
      required this.defaultLoginSize,
      })
      : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final double defaultLoginSize;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController =
        new TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? snapshotUserInfo;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void loginUser() async{
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().loginUser(
      email: emailController.text, 
      password: passwordController.text
    );


    if(res == 'success'){
      QuerySnapshot userInfoSnapshot =
              await DatabaseMethods().getUserInfo(emailController.text);
      HelperFunctions.saveUserLoggedInSharedPrefrence(true);
      HelperFunctions.saveUserEmailSharedPrefrence(
              userInfoSnapshot.docs[0]["email"]);
      HelperFunctions.saveUserNameharedPrefrence(
              userInfoSnapshot.docs[0]["username"]);
      // Navigate to home screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ResponsiveLayout(mobileScreenLayout: MobileScreenLayout(), webScreenLayout: WebScreenLayout(),)));
      setState(() {
        _isLoading = false;
      });
    }else{
      setState(() {
        _isLoading = false;
      });
      showSnackbar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Duration initialDelay = Duration(seconds: 1);
    
    return AnimatedOpacity(
      opacity: widget.isLogin ? 1.0 : 0.0,
      duration: widget.animationDuration * 4,
      child: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            width: widget.size.width,
            height: widget.defaultLoginSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DelayedDisplay(
                  delay: initialDelay,
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                    height: 150,
                    child: DelayedDisplay(
                      delay: Duration(seconds: initialDelay.inSeconds + 1),
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    )),
                SizedBox(
                  height: 20,
                ),
                DelayedDisplay(
                  delay: Duration(seconds: initialDelay.inSeconds + 2),
                  child: RoundedInput(
                    icon: Icons.mail,
                    hint: 'Email Address',
                    controller: emailController,
                    type: TextInputType.emailAddress,
                    function: (value) {
                      if (value!.isEmpty) {
                        return ("Please Enter Your Email");
                      }
                      // reg expression for email validation
                      if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                          .hasMatch(value)) {
                        return ("Please enter a valid email");
                      }
                      return null;
                    },
                    action: TextInputAction.next,
                  ),
                ),
                DelayedDisplay(
                  delay: Duration(seconds: initialDelay.inSeconds + 3),
                  child: RoundedPasswordInput(
                    hint: 'Password',
                    controller: passwordController,
                    function: (value) {
                      RegExp regex = new RegExp(r'^.{6,}$');
                      if (value!.isEmpty) {
                        return ("Password is required for login");
                      }
                      if (!regex.hasMatch(value)) {
                        return ("'Enter a valid password with a minimum of 6 characters");
                      }
                    },
                    action: TextInputAction.done, 
                  ),
                ),
                DelayedDisplay(
                  delay: Duration(seconds: initialDelay.inSeconds +3),
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPassword()));
                      },
                      child: Text(
                        '                                                  Forgot Password?', 
                        style: TextStyle(color: kPrimaryColor, fontSize:15),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height:20,
                ),
                DelayedDisplay(
                    delay: Duration(seconds: initialDelay.inSeconds + 4),
                    child: RoundedButton(
                      child: !_isLoading
                      ? const Text(
                          'LOGIN',
                          style: TextStyle(
                                    color: Colors.white, fontSize: 18)
                        )
                      : const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 5,
                      ),
                      onTap: loginUser,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
