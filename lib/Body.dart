import 'package:flutter/material.dart';
import 'ResultTile.dart';

class Body extends StatefulWidget {
  final Function currentVideoCallback;
  List<Map<String, dynamic>>? searchResults;

  Body({Key? key, required this.currentVideoCallback, this.searchResults})
      : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Widget _displayResults() {
    if (widget.searchResults != null) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: ResultTile(
          videoItems: widget.searchResults,
          currentVideoCallback: widget.currentVideoCallback,
          parentWidget: 'Body',
        ),
      );
    } else {
      return const Center(
          child: Text(
        'Search for a video',
        style: TextStyle(color: Colors.white),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    print("this is body");
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: _displayResults(),
      ),
    );
  }
}
