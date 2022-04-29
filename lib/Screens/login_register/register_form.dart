import 'package:email_auth/email_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hyphen/Screens/AccountSetup/verify_account.dart';
import 'package:hyphen/components/rounded_button.dart';
import 'package:hyphen/components/rounded_input.dart';
import 'package:hyphen/components/rounded_password_input.dart';


class RegisterForm extends StatefulWidget {
  const RegisterForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
    required this.size,
    required this.defaultLoginSize,
    required this.onChanged,
  }) : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final double defaultLoginSize;
  final Function(String) onChanged;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // editing Controller
  final firstNameEditingController = new TextEditingController();
  final secondNameEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final userNameEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();
  final confirmPasswordEditingController = new TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailEditingController.dispose();
    firstNameEditingController.dispose();
    secondNameEditingController.dispose();
    userNameEditingController.dispose();
    passwordEditingController.dispose();
    confirmPasswordEditingController.dispose();
  }

  void sendOTP() async {
    EmailAuth emailAuth = new EmailAuth(sessionName: "Email Verification");
    var res = await emailAuth.sendOtp(
        recipientMail: emailEditingController.text, otpLength: 6);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedOpacity(
        opacity: widget.isLogin ? 0.0 : 1.0,
        duration: widget.animationDuration * 5,
        child: Visibility(
          visible: !widget.isLogin,
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                width: widget.size.width,
                height: widget.defaultLoginSize,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 80,
                          width: 150,
                          color: Colors.transparent,
                          child: SvgPicture.asset('assets/images/logo.svg')),
                      RoundedInput(
                        icon: Icons.face_sharp,
                        hint: 'First Name',
                        controller: firstNameEditingController,
                        type: TextInputType.name,
                        function: (value) {
                          // name must be at least 3 characters
                          if (value!.isEmpty) {
                            return ("First Name cannot be Empty");
                          }
                          //base case
                          return null;
                        },
                        action: TextInputAction.next,
                      ),
                      RoundedInput(
                        icon: Icons.face_sharp,
                        hint: 'Second Name',
                        controller: secondNameEditingController,
                        type: TextInputType.name,
                        function: (value) {
                          if (value!.isEmpty) {
                            return ("Second Name cannot be Empty");
                          }
                          // base case
                          return null;
                        },
                        action: TextInputAction.next,
                      ),
                      RoundedInput(
                        icon: Icons.mail,
                        hint: 'Email',
                        controller: emailEditingController,
                        type: TextInputType.emailAddress,
                        function: (value) {
                          if (value!.isEmpty) {
                            return ("Please enter your email");
                          }
                          // reg expression for email validation
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return ("Enter a valid email address");
                          }
                          //base case
                          return null;
                        },
                        action: TextInputAction.next,
                      ),
                      RoundedInput(
                        icon: Icons.account_circle,
                        hint: 'Username',
                        controller: userNameEditingController,
                        type: TextInputType.text,
                        function: (value) {
                          if (value!.isEmpty) {
                            return ("Username field cannot be empty");
                          }
                          // reg expression for username validation
                          RegExp regex = new RegExp(r'^.{3,}$');
                          if (!regex.hasMatch(value)) {
                            return ("Enter a valid username with a minimum of 3 characters");
                          }
                          // base case
                          return null;
                        },
                        action: TextInputAction.next,
                      ),
                      RoundedPasswordInput(
                        hint: 'Password',
                        controller: passwordEditingController,
                        function: (value) {
                          RegExp regex = new RegExp(r'^.{6,}$');
                          if (value!.isEmpty) {
                            return ("Password is required for login");
                          }
                          if (!regex.hasMatch(value)) {
                            return ("Enter a valid password with a minimum of 6 characters");
                          }
                        },
                        action: TextInputAction.next,
                      ),
                      RoundedPasswordInput(
                        hint: 'Confirm Password',
                        controller: confirmPasswordEditingController,
                        function: (value) {
                          if (confirmPasswordEditingController.text !=
                              passwordEditingController.text) {
                            return "Password don't match";
                          }
                          return null;
                        },
                        action: TextInputAction.done,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RoundedButton(
                          child: Text('SIGN UP',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                          onTap: () {
                            sendOTP();
                            setState(() {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => VerifyAccount(
                                        emailController: emailEditingController,
                                        firstNameController:
                                            firstNameEditingController,
                                        secondNameController:
                                            secondNameEditingController,
                                        userNameController:
                                            userNameEditingController,
                                        passwordController:
                                            passwordEditingController,
                                      )));
                            });
                          })
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
