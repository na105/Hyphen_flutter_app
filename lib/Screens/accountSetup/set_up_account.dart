import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/components/dropdown/gf_dropdown.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hyphen/components/icon_and_text.dart';
import 'package:hyphen/components/input_container.dart';
import 'package:hyphen/components/rounded_button.dart';
import 'package:hyphen/constants.dart';
import 'package:hyphen/resources/firestore_methods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

import '../../components/app_bar.dart';
import '../../components/build_dot.dart';
import '../../utils/utils.dart';
import 'intro_slides.dart';

class SetUpAccount extends StatefulWidget {
  const SetUpAccount({Key? key}) : super(key: key);

  @override
  _SetUpAccountState createState() => _SetUpAccountState();
}

class _SetUpAccountState extends State<SetUpAccount> {
  Uint8List? _image;
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;

  static final List<NewObject> occupations = <NewObject>[
    NewObject(title: 'Artist', icon: Icons.brush_rounded),
    NewObject(title: 'Student', icon: Icons.school_rounded),
    NewObject(title: 'Content Creator', icon: Icons.computer_rounded),
    NewObject(title: 'Brand Marketer', icon: Icons.format_color_text_rounded),
    NewObject(title: 'General User', icon: Icons.person_outline_rounded)
  ];

  NewObject? occValue;
  List intrestsValue = [];

  selectImage() async {
    Uint8List im = await pickImage(
      ImageSource.gallery,
    );
    setState(() {
      _image = im;
    });
  }

  void updateUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await FireStoreMethods().addUserDetails(
        _bioController.text,
        _image != null
            ? _image!
            : (await NetworkAssetBundle(Uri.parse(
                        'https://www.personality-insights.com/wp-content/uploads/2017/12/default-profile-pic-e1513291410505.jpg'))
                    .load(
                        'https://www.personality-insights.com/wp-content/uploads/2017/12/default-profile-pic-e1513291410505.jpg'))
                .buffer
                .asUint8List(),
        occValue!.title,
        intrestsValue);

    if (res == 'success') {
      setState(() {
        _isLoading = false;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => IntroSlides()));
      });
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
          body: CustomScrollView(slivers: [
            const appBar(),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: height * .03),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              'Set up your profile',
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Stack(
                            children: [
                              _image != null
                                  ? CircleAvatar(
                                      radius: 64,
                                      backgroundImage: MemoryImage(_image!),
                                      backgroundColor: Colors.white,
                                    )
                                  : const CircleAvatar(
                                      radius: 64,
                                      backgroundImage: NetworkImage(
                                          'https://www.personality-insights.com/wp-content/uploads/2017/12/default-profile-pic-e1513291410505.jpg'),
                                      backgroundColor: Colors.white,
                                    ),
                              Positioned(
                                bottom: -10,
                                left: 80,
                                child: IconButton(
                                  onPressed: selectImage,
                                  icon: const Icon(Icons.add_a_photo),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              buildDot(
                                width: width * 0.022,
                                height: width * 0.022,
                                color: Colors.grey,
                              ),
                              buildDot(
                                  width: width * 0.055,
                                  height: width * 0.022,
                                  color: kPrimaryColor),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          InputContainer(
                              child: TextFormField(
                            cursorColor: kPrimaryColor,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.text_snippet_outlined,
                                    color: kPrimaryColor),
                                hintText: "Bio",
                                border: InputBorder.none),
                            keyboardType: TextInputType.text,
                            controller: _bioController,
                          )),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: MediaQuery.of(context).size.height / 13,
                            child: DropdownButtonHideUnderline(
                              child: GFDropdown(
                                borderRadius: BorderRadius.circular(30),
                                border: BorderSide(
                                    color: kPrimaryColor.withAlpha(50),
                                    width: 0.5),
                                dropdownButtonColor: const Color(0xffced2d9),
                                value: occValue,
                                hint: Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Icon(
                                      Icons.work_sharp,
                                      color: kPrimaryColor,
                                      size: 22,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text('Occupation')
                                  ],
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    occValue = newValue as NewObject?;
                                  });
                                },
                                items: occupations
                                    .map((value) => DropdownMenuItem(
                                          value: value,
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Icon(value.icon,
                                                  color: kPrimaryColor),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              Text(value.title)
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor.withAlpha(50)),
                            child: MultiSelectFormField(
                              autovalidate: AutovalidateMode.disabled,
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              fillColor: Colors.transparent,
                              dialogTextStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              checkBoxActiveColor: const Color(0xFF182F50),
                              checkBoxCheckColor: Colors.white,
                              dialogShapeBorder: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              title: Text(
                                'Interests',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey.shade600),
                              ),
                              dataSource: intrests,
                              textField: 'interest',
                              valueField: 'value',
                              okButtonLabel: 'OK',
                              cancelButtonLabel: 'CANCEL',
                              hintWidget:
                                  const Text('Select one or more interests'),
                              initialValue: intrestsValue,
                              onSaved: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  intrestsValue = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          RoundedButton(
                              child: !_isLoading
                                  ? const Text('FINISH',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18))
                                  : const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 5,
                                    ),
                              onTap: () {
                                if (intrestsValue.isEmpty) {
                                  showSnackbar(
                                      context, 'Please fill the empty fields');
                                } else {
                                  updateUser();
                                }
                              }),
                          const SizedBox(
                            height: 15,
                          )
                        ]),
                  ),
                ],
              ),
            ),
          ])),
    );
  }
}
