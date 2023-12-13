import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunetube/PlaylistStateManagement.dart';
import 'BottomPlayer.dart';
import 'MyAppBar.dart';
import 'Body.dart';
import 'Drawer.dart';
import 'Playlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>>? searchResults;
  List<Map<String, dynamic>>? playlist;
  Map<String, dynamic>? currentVideo;
  bool playlistPlaying = false;

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); //for Drawer

  @override
  Widget build(BuildContext context) {
    print("this is homeepage");
    return ChangeNotifierProvider(
        create: (context) => PlaylistStateManagement(),
        child: GestureDetector(
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
                  currentVideoCallback: (data) {
                    setState(() {
                      currentVideo = data;
                    });
                  },
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
                          currentVideoCallback: (data) {
                            setState(() {
                              currentVideo = data;
                            });
                          }),
                    ),
                  ],
                )),
                //--------------- music player ---------------
                bottomNavigationBar: BottomPlayer(
                  searchResults: searchResults,
                  currentVideo: currentVideo,
                ))));
  }
}
