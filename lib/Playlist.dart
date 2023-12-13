import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunetube/MySnackbar.dart';
import 'package:tunetube/PlaylistHeader.dart';
import 'package:tunetube/PlaylistStateManagement.dart';
import 'ResultTile.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class PlaylistDrawer extends StatefulWidget {
  List<Map<String, dynamic>>? playlist;
  final Function currentVideoCallback;

  PlaylistDrawer({
    Key? key,
    required this.playlist,
    required this.currentVideoCallback,
  }) : super(key: key);


  @override
  _PlaylistDrawerState createState() => _PlaylistDrawerState();
}

class _PlaylistDrawerState extends State<PlaylistDrawer> {
  @override
  Future<void> _readPlaylist() async {
    try {
      if (Platform.isAndroid) {
        // For Android, read the file from the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/playlist.txt');
        await _readFile(file);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop, read the file from the project directory
        final file = File('lib/playlist.txt');
        await _readFile(file);
      }
    } catch (e) {
      print('Failed to read playlist: $e');
      //clear playlist file
      if (Platform.isAndroid) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/playlist.txt');
        await file.writeAsString('');
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final file = File('lib/playlist.txt');
        await file.writeAsString('');
      }
      //display snackbar
      ScaffoldMessenger.of(context).showSnackBar(MySnackbar.show(
          'Playlist was cleared due to an error. Please create a new playlist.'));
    }
  }

  Future<void> _readFile(File file) async {
    if (await file.exists()) {
      final fileContent = await file.readAsString();
      final lines = LineSplitter.split(fileContent);
      widget.playlist = lines
          .map((line) => jsonDecode(line))
          .cast<Map<String, dynamic>>()
          .toList();
      print("Playlist read.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _readPlaylist(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
              child: Center(child: CircularProgressIndicator()));
        } else {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: SafeArea(
              child: Drawer(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        //----------- Header ------------
                        const PlaylistHeader(),
                        //------
                        // Check if playlist is empty
                        widget.playlist?.isEmpty ?? true
                            ? const Expanded(
                                child: Center(
                                  child: Text(
                                    'Playlist is empty',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            :
                            //-------- Songs list starts here -------------
                            Expanded(
                                child: ListView(children: [
                                ResultTile(
                                  videoItems: widget.playlist,
                                  currentVideoCallback:  widget.currentVideoCallback,
                                  parentWidget: 'Playlist',
                                )
                              ])),
                      ],
                    )),
              ),
            ),
          );
        }
      },
    );
  }
}
