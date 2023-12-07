import 'package:flutter/material.dart';
import 'BottomPlayer.dart';
import 'MyAppBar.dart';
import 'Body.dart';
import 'Drawer.dart';
import 'SearchResults.dart';
import 'Playlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>>? searchResults = null;
  List<Map<String, dynamic>>? playlist = null;
  Map<String, dynamic>? metadata = null;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); //for Drawer

  @override
  Widget build(BuildContext context) {
    print("this is homeepage");
    return GestureDetector(
        onHorizontalDragEnd: (details) {
           if (details.primaryVelocity! > 0) {
            _scaffoldKey.currentState?.openDrawer(); // Open left drawer
          } else if (details.primaryVelocity! < 0) {
            _scaffoldKey.currentState?.openEndDrawer(); // Open right drawer
          }
        },
        child: Scaffold(
            key: _scaffoldKey,
            drawer: MyDrawer(),
            endDrawer: PlaylistDrawer(
              playlist: playlist,
            ),
            body: SafeArea(
                child: Column(
              children: [
                // ---------------- AppBar ---------------
                MyAppBar(
                  searchResultsCallBack: (str) {
                    setState(() {
                      searchResults = str;
                    });
                  },
                  scaffoldKey: _scaffoldKey,
                ),

                //--------------- body ---------------
                Expanded(
                  child: Body(
                      searchResults: searchResults,
                      playlist: playlist,
                      metadataCallback: (data) {
                        setState(() {
                          metadata = data;
                        });
                      }),
                ),
              ],
            )),

            //--------------- music player ---------------
            bottomNavigationBar: BottomPlayer(
              searchResults: searchResults,
              metadata: metadata,
            )));
  }
}
