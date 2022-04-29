import 'package:flutter/material.dart';
import 'package:hyphen/components/input_container.dart';
import 'package:hyphen/constants.dart';


class RoundedInput extends StatelessWidget {
  const RoundedInput({
    Key? key,
    required this.icon,
    required this.hint,
    required this.controller,
    required this.type,
    required this.function,
    required this.action,
  }) : super(key: key);

  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final TextInputType type;
  final String? Function(String?) function;
  final TextInputAction action;

  @override
  Widget build(BuildContext context) {
    return InputContainer(
      child: TextFormField(
        
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          icon: Icon(icon, color: kPrimaryColor),
          hintText: hint,
          labelText: hint,
          border: InputBorder.none
        ),
        controller: controller,
        keyboardType: type,
        validator: function,
        textInputAction: action,
      ),
    );
  }
}

