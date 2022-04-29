import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async{
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source);

  if(_file != null){
    return await _file.readAsBytes();
  }else{
    return;
  }
}

// for displaying snackbars
showSnackbar(BuildContext context, String text){
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text)
    )
  );
}