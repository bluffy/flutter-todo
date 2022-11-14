import 'package:flutter/material.dart';

class CustomDialog {
  static showAlertDialog(
      {required BuildContext context,
      required String text,
      String? titel,
      String? okText,
      onPressed}) {
    var _okText = "OK";
    if (okText != null) {
      _okText = okText;
    }

    Widget okButton;
    // set up the button
    if (onPressed != null) {
      okButton = TextButton(
        child: Text(_okText),
        onPressed: onPressed,
      );
    } else {
      okButton = TextButton(
        child: Text(_okText),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: (titel != null) ? Text(titel) : null,
      content: Text(text),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showConfirmDialog(
      {required BuildContext context,
      required String text,
      required onPressedOk,
      String? titel,
      String? okText,
      String? cancleText,
      onPressedCancle}) {
    String _okText = "OK";
    if (okText != null) {
      _okText = okText;
    }
    String _cancleText = "Cancle";
    if (cancleText != null) {
      _cancleText = cancleText;
    }

    Widget cancleButton;
    // set up the button
    if (onPressedOk != null) {
      cancleButton = TextButton(
        onPressed: onPressedCancle,
        child: Text(_cancleText),
      );
    } else {
      cancleButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(_cancleText),
      );
    }

    Widget okButton = TextButton(
      onPressed: onPressedOk,
      child: Text(_okText),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: (titel != null) ? Text(titel) : null,
      content: Text(text),
      actions: [
        cancleButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
