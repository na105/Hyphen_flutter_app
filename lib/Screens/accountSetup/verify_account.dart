import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hyphen/components/build_dot.dart';
import 'package:hyphen/components/input_container.dart';
import 'package:hyphen/components/rounded_button.dart';
import 'package:hyphen/constants.dart';
import 'package:hyphen/resources/auth_methods.dart';
import 'package:hyphen/utils/utils.dart';

import '../../resources/helperFunctions.dart';
import 'set_up_account.dart';

class VerifyAccount extends StatefulWidget {
  const VerifyAccount(
      {Key? key,
      required this.emailController,
      required this.firstNameController,
      required this.secondNameController,
      required this.userNameController,
      required this.passwordController})
      : super(key: key);

  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController secondNameController;
  final TextEditingController userNameController;
  final TextEditingController passwordController;

  @override
  _VerifyAccountState createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _ath = FirebaseAuth.instance;
  EmailAuth emailAuth = new EmailAuth(sessionName: "Email Verification");
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final User? user = _ath.currentUser;
  }

  @override
  void dispose() {
    super.dispose();
    _otpController.dispose();
  }

  void verifyOTP() async {
    var res = emailAuth.validateOtp(
        recipientMail: widget.emailController.text,
        userOtp: _otpController.text);
  }

  void resendOtp() async {
    var res = emailAuth.sendOtp(recipientMail: widget.emailController.text);
  }

  void signUpUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
        firstName: widget.firstNameController.text,
        secondName: widget.secondNameController.text,
        email: widget.emailController.text,
        username: widget.userNameController.text,
        password: widget.passwordController.text);

    if (res == 'success') {
      setState(() {
        HelperFunctions.saveUserLoggedInSharedPrefrence(true);
        HelperFunctions.saveUserEmailSharedPrefrence(
            widget.emailController.text);
        HelperFunctions.saveUserNameharedPrefrence(
            widget.userNameController.text);
        _isLoading = false;
      });

      //navigate to the update profile screen
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SetUpAccount()));
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      showSnackbar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: kPrimaryColor)),
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
            SliverList(
                delegate: SliverChildListDelegate([
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: height * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Email Verification',
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 38,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.only(left: 80, right: 60),
                      child: Text(
                        'Please enter the the verification number sent to your email. ',
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        height: 300,
                        width: 300,
                        color: Colors.transparent,
                        child:
                            SvgPicture.asset('assets/images/collaborate.svg')),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        buildDot(
                          width: width * 0.055,
                          height: width * 0.022,
                          color: kPrimaryColor,
                        ),
                        buildDot(
                            width: width * 0.022,
                            height: width * 0.022,
                            color: Colors.grey),
                      ],
                    ),
                    InputContainer(
                        child: TextFormField(
                      cursorColor: kPrimaryColor,
                      decoration: InputDecoration(
                          icon:
                              Icon(Icons.password_sharp, color: kPrimaryColor),
                          hintText: "OTP",
                          border: InputBorder.none),
                      keyboardType: TextInputType.number,
                      controller: _otpController,
                    )),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: resendOtp,
                        child: Text(
                          '                                                     Resend Email?',
                          style: TextStyle(color: kPrimaryColor, fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 23,
                    ),
                    RoundedButton(
                        child: !_isLoading
                            ? Text('VERIFY',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18))
                            : const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 5,
                              ),
                        onTap: () {
                          verifyOTP();
                          signUpUser();
                        })
                  ],
                ),
              ),
            ]))
          ],
        ),
      ),
    );
  }
}
