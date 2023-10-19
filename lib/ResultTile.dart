import 'package:flutter/material.dart';
import 'package:tunetube/AudioStream.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ResultTile extends StatelessWidget {
  final videoItems;
  final Function metadataCallback;

  const ResultTile({required this.videoItems, required this.metadataCallback});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: videoItems.length,
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
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: videoThumbnailUrl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      title: Text(videoTitle,
                          style: TextStyle(color: Colors.white)),
                      subtitle: Text(videoAuthor,
                          style: TextStyle(color: Colors.white)),
                      onTap: () async {
                        if (videoUrl == null) {
                          print("videoUrl is null");
                          return;
                        }
                        //create a popup that shows progess circle while audioUrl is being fetched
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CircularProgressIndicator(),
                                    Text("Fetching the Audio link..."),
                                  ],
                                ),
                              );
                            });

                        //get audioUrl
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
