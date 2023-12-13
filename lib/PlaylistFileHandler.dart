 import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tunetube/AudioStream.dart';
import 'MySnackbar.dart';

class PlaylistFileHandler {
  static Future<void> saveToPlaylist(
      BuildContext context, Map<String, dynamic> video) async {
    try {
      if (await alreadyExists(video)) {
        ScaffoldMessenger.of(context).showSnackBar(
            MySnackbar.show("Video already exists in the playlist."));
        print('Video already exists in the playlist.');
        return;
      }

      final String audioUrl = await getAudioUrl(video['videoUrl']!);
      video['audioUrl'] = audioUrl;
      String videoJson = jsonEncode(video);

      if (Platform.isAndroid) {
        // For Android, write the file to the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/playlist.txt');
        await file.writeAsString('$videoJson\n', mode: FileMode.append);
        Tooltip(message: "Added to playlist");
        print("Added to playlist.");
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop, write the file to the project directory
        final file = File('lib/playlist.txt');
        await file.writeAsString('$videoJson\n', mode: FileMode.append);
        print("Added to playlist.");
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(MySnackbar.show("Video added to playlist."));
    } catch (e) {
      print('Failed to write to file: $e');
    }
  }

  static Future<bool> alreadyExists(Map<String, dynamic> video) async {
    File file;
    if (Platform.isAndroid) {
      // For Android, read the file from the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      file = File('${directory.path}/playlist.txt');
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop, read the file from the project directory
      file = File('lib/playlist.txt');
    } else {
      return false;
    }

    if (await file.exists()) {
      final lines = await file.readAsLines();
      for (final line in lines) {
        final videoData = jsonDecode(line);
        if (videoData['videoUrl'] == video['videoUrl']) {
          return true;
        }
      }
    }

    return false;
  }

  static void removeFromPlaylist(
      BuildContext context, Map<String, dynamic> video) async {
    try {
      File file;
      if (Platform.isAndroid) {
        // For Android, read the file from the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        file = File('${directory.path}/playlist.txt');
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop, read the file from the project directory
        file = File('lib/playlist.txt');
      } else {
        return;
      }

      if (await file.exists()) {
        final lines = await file.readAsLines();
        final newLines = <String>[];
        for (final line in lines) {
          final videoData = jsonDecode(line);
          if (videoData['videoUrl'] != video['videoUrl']) {
            newLines.add(line);
          }
        }
        await file.writeAsString(newLines.join('\n'));
        ScaffoldMessenger.of(context)
            .showSnackBar(MySnackbar.show("Video removed from playlist."));
        print("Video removed from playlist.");
      }
    } catch (e) {
      print('Failed to write to file playlist.txt: $e');
    }
  }

}
