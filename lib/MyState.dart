import 'package:flutter/material.dart';

class MyState extends ChangeNotifier {
  List<Map<String, dynamic>>? _searchResult = null;
  dynamic _currentlyPlaying = null;
  
  List<Map<String, dynamic>>? get searchResult => _searchResult;
  dynamic get currentlyPlaying => _currentlyPlaying;

  void setCurrentlyPlaying(dynamic currentlyPlaying) {
    _currentlyPlaying = currentlyPlaying;
    notifyListeners();
  }

  void setSearchResult(List<Map<String, dynamic>> searchResult) {
    _searchResult = searchResult;
    notifyListeners();
  }
}
