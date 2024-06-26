import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:tunetube/Body.dart';
import 'package:tunetube/BottomPlayer.dart';
import 'package:tunetube/MyDrawer.dart';
import 'package:tunetube/MyState.dart';
import 'package:tunetube/PlaylistDrawer.dart';
import 'MyAppBar.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey =
    GlobalKey<ScaffoldState>(); //for Drawer

class _HomePageState extends State<HomePage> {

  @override
  void dispose() async {
    super.dispose();
    await Hive.close();
  }

  @override
  Widget build(BuildContext context) {
    print("this is home page");
    return ChangeNotifierProvider(
        create: (context) => MyState(),
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
            endDrawer: PlaylistDrawer(),
            appBar: MyAppBar(
              scaffoldKey: _scaffoldKey,
            ),
            body: 
                Body(),
            bottomNavigationBar: BottomPlayer(),
          )
        ));
  }
}
