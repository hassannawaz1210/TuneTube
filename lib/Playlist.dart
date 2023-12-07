import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ResultTile.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class PlaylistDrawer extends StatefulWidget {
  List<Map<String, dynamic>>? playlist;
  PlaylistDrawer({Key? key, this.playlist}) : super(key: key);

  @override
  _PlaylistDrawerState createState() => _PlaylistDrawerState();
}

class _PlaylistDrawerState extends State<PlaylistDrawer> {
  @override

  Future<void> _readPlaylist() async {
    print("READING PLAYLIST");
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
          return Drawer(child: Center(child: CircularProgressIndicator())); // Show loading indicator while waiting
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                              color: Colors.white, width: 2.0), 
                          ),
                        child: ListTile(
                          title: const Text(
                            'Playlist',
                            style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            color: Colors.white,
                            onPressed: () async {},
                          ),
                        ),
                      ),

                      //-------- Songs list starts here -------------
                      ResultTile(
                        videoItems: widget.playlist,
                        metadataCallback: (data) {},
                      ),
                    ],
                  )
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

