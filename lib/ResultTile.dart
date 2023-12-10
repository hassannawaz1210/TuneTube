import 'package:flutter/material.dart';
import 'package:tunetube/AudioStream.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tunetube/PlaylistFileHandler.dart';

class ResultTile extends StatefulWidget {
  final videoItems;
  final Function currentVideoCallback;
  String parentWidget;

  ResultTile({
    Key? key,
    required this.videoItems,
    required this.currentVideoCallback,
    required this.parentWidget,
  }) : super(key: key);

  @override
  _ResultTileState createState() => _ResultTileState();
}

class _ResultTileState extends State<ResultTile> {
  @override
  Widget build(BuildContext context) {
    print("this is result tile");
    IconData trailingIcon = Icons.add;
    if (widget.parentWidget == 'Playlist') {
      trailingIcon = Icons.remove;
    }

    void refreshWidget(int index) {
      if (mounted) {
        setState(() {
          widget.videoItems.removeAt(index);
        });
      }
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: widget.videoItems?.length ?? 0,
          itemBuilder: (context, index) {
            final video = widget.videoItems[index];
            final videoTitle = video['title'];
            final videoThumbnailUrl = video['thumbnails'];
            final videoAuthor = video['author'];
            final videoUrl = video['videoUrl'];

            return Material(
                color: Colors.transparent,
                child: ListTile(
                  //add addition button
                  trailing: IconButton(
                    icon: Icon(trailingIcon, color: Colors.white),
                    onPressed: () {
                      if (widget.parentWidget == 'Body') {
                        PlaylistFileHandler.saveToPlaylist(context, video);
                      } else if (widget.parentWidget == 'Playlist') {
                        PlaylistFileHandler.removeFromPlaylist(context, video);
                        //remove from playlist and refresh widget
                        refreshWidget(index);
                      }
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    widget.currentVideoCallback(metadata);
                  },

                  // Add more widgets to display other video information.
                ));
          },
        );
      },
    );
  }
}
