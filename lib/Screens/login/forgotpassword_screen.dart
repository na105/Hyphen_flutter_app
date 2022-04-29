import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyphen/components/rounded_button.dart';
import 'package:hyphen/constants.dart';
import 'package:hyphen/utils/utils.dart';

import '../../components/rounded_input.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = new TextEditingController();
  bool _isLoading = false;

  Future resetPassword() async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      showSnackbar(context, "Password Reset Email Sent Sucessfully");
      setState(() {
        Navigator.of(context).pop();
      });
    }on FirebaseAuthException catch(e){
      showSnackbar(context,e.toString());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_sharp,
              size: 30,
              color: kPrimaryColor,
            )),
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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(MediaQuery.of(context).size.width / 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 14),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor),
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.only(left: 50, right: 20),
                child: Text(
                  'Please enter your email address to send a reset password link. ',
                  style: TextStyle(
                      color: Color.fromRGBO(69, 90, 100, 1),
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                  height: 250,
                  width: 250,
                  color: Colors.transparent,
                  child: SvgPicture.asset('assets/images/forgot.svg')),
              SizedBox(
                height: 20,
              ),
              RoundedInput(
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
                action: TextInputAction.done,
              ),
              SizedBox(
                height: 20,
              ),
              RoundedButton(
                  child: !_isLoading
                      ? Text('SEND',
                          style: TextStyle(color: Colors.white, fontSize: 18))
                      : const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 5,
                        ),
                  onTap: () {
                    resetPassword();
                  })
            ],
          ),
        ),
      ),
    );
  }
}
