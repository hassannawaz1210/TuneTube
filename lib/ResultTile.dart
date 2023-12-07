import 'package:flutter/material.dart';
import 'package:tunetube/AudioStream.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class ResultTile extends StatelessWidget {
  final videoItems;
  final Function metadataCallback;
  List<Map<String, dynamic>>? playlist;

  ResultTile({required this.videoItems, required this.metadataCallback});

  Future<void> saveToPlaylist(Map<String, dynamic> video) async {
    try {
      String videoJson = jsonEncode(video);

      if (Platform.isAndroid) {
        // For Android, write the file to the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/playlist.txt');
        await file.writeAsString('$videoJson\n', mode: FileMode.append);
        print("Added to playlist.");
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop, write the file to the project directory
        final file = File('lib/playlist.txt');
        await file.writeAsString('$videoJson\n', mode: FileMode.append);
        print("Added to playlist.");
      }
    } catch (e) {
      print('Failed to write to file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: videoItems?.length ?? 0,
          itemBuilder: (context, index) {
            final video = videoItems[index];
            final videoTitle = video['title'];
            final videoThumbnailUrl = video['thumbnails'];
            final videoAuthor = video['author'];
            final videoUrl = video['videoUrl'];

            return Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () {},
                    splashColor: Colors.white,
                    child: ListTile(
                      //add addition button
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        color: Colors.white,
                        onPressed: () async {
                          // if (playlist == null) {
                          //   playlist = [];
                          // }
                          // playlist!.add(video);
                          // print("Added to playlist.");

                          //save to playlist
                          await saveToPlaylist(video);
                        },
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: videoThumbnailUrl,
                          placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Padding(
                              padding: EdgeInsets.only(left: 10, top: 10),
                              child: Icon(Icons.error, color: Colors.white)),
                        ),
                      ),
                      title: Text(videoTitle,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(videoAuthor,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () async {
                        if (videoUrl == null) {
                          print("videoUrl is null");
                          return;
                        }
                        //create a popup that shows progess circle while audioUrl is being fetched
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    LoadingAnimationWidget.threeArchedCircle(
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                    Text("Fetching the Audio link..."),
                                  ],
                                ),
                              );
                            });

                        //get audioUrl
                        print(videoUrl);
                        final audioUrl = await getAudioUrl(videoUrl);
                        Navigator.pop(context);

                        Map<String, dynamic> metadata = {
                          'title': videoTitle,
                          'author': videoAuthor,
                          'thumbnail': videoThumbnailUrl,
                          'videoUrl': videoUrl,
                          'audioUrl': audioUrl,
                        };
                        metadataCallback(metadata);
                      },

                      // Add more widgets to display other video information.
                    )));
          },
        );
      },
    );
  }
}
