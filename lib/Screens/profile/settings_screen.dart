// Edit profile screen, accessible through the profile screen

import 'package:flutter/material.dart';
import 'package:hyphen/Screens/profile/edit_profile.dart';
import 'package:hyphen/Screens/login/login.dart';
import '../../resources/auth_methods.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
          child: ListView(
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 40.0,
              ),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  const Text('Account',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                ],
              ),
              const Divider(
                height: 15,
                thickness: 2,
              ),
              InkWell(onTap: () {
                setState(() {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const EditProfile()));
                });
                child:
                buildAccountOptions(context, 'Edit Profile');
              }),
              buildAccountOptions(context, 'Delete Account'),
              const SizedBox(
                height: 40.0,
              ),
              Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  const Text('Security',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                ],
              ),
              const Divider(
                height: 15,
                thickness: 2,
              ),
              buildAccountOptions(context, 'Change Password'),
              const SizedBox(
                height: 40.0,
              ),
              Row(
                children: [
                  Icon(
                    Icons.volume_up_outlined,
                    color: Colors.blue.shade900,
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  const Text('Notifications',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                ],
              ),
              const Divider(
                height: 15,
                thickness: 2,
              ),
              buildNotificationOptions("Option 1", false),
              buildNotificationOptions("Option 2", false),
              buildNotificationOptions("Option 3", true),
              buildNotificationOptions("Option 4", false),
              const SizedBox(
                height: 50.0,
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      await AuthMethods().signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign Out',
                        style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                ),
              ),
              const SizedBox(
                height: 50.0,
              ),
            ],
          ),
        ));
  }

  Row buildNotificationOptions(String option, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          option,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Switch(value: isActive, onChanged: (bool val) {})
      ],
    );
  }

  Padding buildAccountOptions(BuildContext context, String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            option,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Icon(
            Icons.arrow_forward,
            color: Colors.blue.shade900,
          )
        ],
      ),
    );
  }
}
