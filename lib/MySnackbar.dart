import 'package:flutter/material.dart';

class MySnackbar {

  static SnackBar show(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.white,
      content: Text(
        message,
        style: const TextStyle(color: Colors.black),
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
    return snackBar;
  }

}