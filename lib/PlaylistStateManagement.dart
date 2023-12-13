import 'package:flutter/material.dart';

class PlaylistStateManagement with ChangeNotifier {
  bool _buttonPressed = false;

  bool get buttonPressed => _buttonPressed;

  void setButtonPressed(bool value) {
    _buttonPressed = value;
    notifyListeners();
  }
}