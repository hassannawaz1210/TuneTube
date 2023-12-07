import 'package:flutter/material.dart';
import 'ResultTile.dart';

class Body extends StatefulWidget {
  final Function metadataCallback;
  List<Map<String, dynamic>>? searchResults;
  List<Map<String, dynamic>>? playlist;

  Body(
      {required this.searchResults,
      required this.playlist,
      required this.metadataCallback});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body>  {
  Widget _buildSearchQuery() {
    if (widget.searchResults != null) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: ResultTile(
          videoItems: widget.searchResults,
          metadataCallback: widget.metadataCallback,
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
        child: _buildSearchQuery(),
      ),
    );
  }
}
