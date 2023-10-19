import 'package:flutter/material.dart';
import 'ButtomPlayer.dart';
import 'AppBar.dart';
import 'Body.dart';
import 'Drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? searchString = null;
  Map<String, dynamic>? metadata = null;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    print("this is homeepage");
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _scaffoldKey.currentState?.openDrawer();
        }
      },
      child: Scaffold(
          key: _scaffoldKey,
          drawer: MyDrawer(),
          body: SafeArea(
              child: Column(
            children: [
              // ---------------- AppBar ---------------
              MyAppBar(
                setSearchString: (str) {
                  setState(() {
                    searchString = str;
                  });
                },
                scaffoldKey: _scaffoldKey,
              ),

              // --------------- Search Results ---------------
              
                
              //--------------- body ---------------
              Expanded(
                child: Body(
                    searchString: searchString,
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
            metadata: metadata,
          ))
    );
  }
}
