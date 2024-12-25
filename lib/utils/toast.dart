import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

abstract class Toast {
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}