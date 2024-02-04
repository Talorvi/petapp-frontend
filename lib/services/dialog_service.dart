import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class DialogService {
  static showErrorDialog(String text, BuildContext context) {
    AwesomeDialog(
            context: context,
            animType: AnimType.scale,
            dialogType: DialogType.error,
            headerAnimationLoop: false,
            title: text,
            btnOkOnPress: () {},
            btnOkColor: Colors.red)
        .show();
  }

  static showSuccessDialog(String text, BuildContext context) {
    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.success,
      headerAnimationLoop: false,
      title: text,
      btnOkOnPress: () {},
    ).show();
  }
}
