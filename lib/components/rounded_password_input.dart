import 'package:flutter/material.dart';
import 'package:hyphen/components/input_container.dart';
import 'package:hyphen/constants.dart';


class RoundedPasswordInput extends StatefulWidget {
  const RoundedPasswordInput({
    Key? key,
    required this.hint,
    required this.controller,
    required this.function,
    required this.action,
  }) : super(key: key);

  final String hint;
  final TextEditingController controller;
  final String? Function(String?) function;
  final TextInputAction action;

  @override
  State<RoundedPasswordInput> createState() => _RoundedPasswordInputState();
}

class _RoundedPasswordInputState extends State<RoundedPasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return InputContainer(
      child: TextFormField(
        cursorColor: kPrimaryColor,
        obscureText: _obscureText,
        decoration: InputDecoration(
          icon: Icon(Icons.lock, color: kPrimaryColor),
          hintText: widget.hint,
          labelText: widget.hint,
          border: InputBorder.none,
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              icon: Icon( _obscureText 
              ? Icons.visibility_off
              : Icons.visibility,
              ),
              color: kPrimaryColor,
          )
        ),
        controller: widget.controller,
        validator: widget.function,
        textInputAction: widget.action,
      ),
    );
  }
}
