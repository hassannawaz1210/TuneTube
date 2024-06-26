import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunetube/MyState.dart';
import 'ResultTile.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  Widget _displayResults() {
  return Selector<MyState, List<Map<String, dynamic>>?>(
    selector: (_, myState) => myState.searchResult,
    builder: (context, searchResult, child) {
      var _searchResult = searchResult;
      if (_searchResult != null) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: ResultTile(),
        );
      } else {
        return const Center(
          child: Text(
            'Search for a video',
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    },
  );
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