import 'package:flutter/material.dart';
import 'SearchQuery.dart';

class Body extends StatefulWidget {
  final String? searchString;
  final Function metadataCallback;

  const Body({required this.metadataCallback, this.searchString});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body>  {
  Widget _buildSearchQuery() {
    if (widget.searchString != null) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: SearchResults(query: widget.searchString!, metadataCallback: widget.metadataCallback),
      );
    } else {
      return Center(
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
