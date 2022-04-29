import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:password_validated_field/password_validated_field.dart';

import 'package:hyphen/components/rounded_button.dart';
import 'package:hyphen/constants.dart';
import 'package:hyphen/resources/auth_methods.dart';
import 'package:hyphen/utils/utils.dart';

import '../../components/rounded_password_input.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldPasswordEditingController =
      new TextEditingController();
  TextEditingController newPasswordEditingController =
      new TextEditingController();
  TextEditingController confirmNewPasswordEditingController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_sharp,
              size: 25,
              color: kPrimaryColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
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
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 11),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height /10,),
                Title(
                    color: Color(0xFF182F50),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        color: Color(0xFF182F50),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      
                      textAlign: TextAlign.center,
                    )),
                SizedBox(height: MediaQuery.of(context).size.height /10,),
                RoundedPasswordInput(
                  hint: 'Old Password',
                  controller: oldPasswordEditingController,
                  function: (value) {
                    RegExp regex = new RegExp(r'^.{6,}$');
                    if (value!.isEmpty) {
                      showSnackbar(
                          context, "Old password is required for update");
                    }
                    if (!regex.hasMatch(value)) {
                      showSnackbar(context,
                          "Enter a valid password with a minimum of 6 characters");
                    }
                  },
                  action: TextInputAction.next,
                ),
                RoundedPasswordInput(
                  hint: 'New Password',
                  controller: newPasswordEditingController,
                  function: (value) {
                    RegExp regex = new RegExp(r'^.{6,}$');
                    if (value!.isEmpty) {
                      showSnackbar(
                          context, "New Password is required for update");
                    }
                    if (!regex.hasMatch(value)) {
                      showSnackbar(context,
                          "Enter a valid password with a minimum of 6 characters");
                    }
                  },
                  action: TextInputAction.next,
                ),
                RoundedPasswordInput(
                  hint: 'Confirm New Password',
                  controller: confirmNewPasswordEditingController,
                  function: (value) {
                    if (confirmNewPasswordEditingController.text !=
                        newPasswordEditingController.text) {
                      showSnackbar(
                          context, "Password does not match with new password");
                    }
                    return null;
                  },
                  action: TextInputAction.done,
                ),
                SizedBox(
                  height: 20,
                ),
                RoundedButton(
                    child: Text('UPDATE',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    onTap: () {
                      AuthMethods().updateEmailPassword(
                          oldPasswordEditingController.text,
                          newPasswordEditingController.text,
                          context);
                    })
              ],
            ),
          ),
        ));
  }
}
