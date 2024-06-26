import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunetube/API.dart';
import 'package:tunetube/Boxes.dart';
import 'package:tunetube/MyState.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tunetube/models/PlaylistItem.dart';
import 'MySnackbar.dart';

class ResultTile extends StatelessWidget {
  ResultTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MyState>(
      builder: (context, myState, child) {
        return ListView.builder(
          itemCount: myState.searchResult!.length,
          itemBuilder: (context, index) {
            String title = myState.searchResult![index]['title'];
            String channel = myState.searchResult![index]['author'];
            String thumbnail = myState.searchResult![index]['thumbnails'];
            return ListTile(
              leading: CachedNetworkImage(
                  imageUrl: thumbnail,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Color.fromARGB(184, 255, 255, 255)),
                  imageBuilder: (context, imageProvider) => Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      )),
              title: Text(title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(channel,style: const TextStyle(color: Colors.white),),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                color: Colors.white,
                onPressed: () async {
                  final selectedItem = myState.searchResult![index];
                  final playlistItem = PlaylistItem(
                    title: selectedItem['title'],
                    author: selectedItem['author'],
                    videoUrl: selectedItem['videoUrl'],
                    thumbnails: selectedItem['thumbnails'],
                    description: selectedItem['description'],
                    duration: selectedItem['duration'],
                  );
                  final playlist = Boxes.getPlaylist();

                  final addedItemKey = playlist.add(playlistItem);
                  final key = await addedItemKey;
                  print("added item key: " + key.toString());
                  ScaffoldMessenger.of(context)
                      .showSnackBar(MySnackbar.show('Added to playlist'));
                  print("Added to playlist");

                  //Asynchronously Fetch the audioUrl for the playlist item
                  getAudioUrl(playlistItem.videoUrl).then((audioUrl) {
                    playlistItem.audioUrl = audioUrl;
                    playlist.put(key, playlistItem);
                    print("audio url fetched successfully.");
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(MySnackbar.show(
                        'Couldnt fetch the audioUrl for the playlist item.'));
                    print('Error: $error');
                  });
                },
              ),
              onTap: () async {
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

                //fetch the audioUrl
                Map<String, dynamic>? currentlyPlaying =
                    myState.searchResult![index];
                String audioUrl =
                    await getAudioUrl(currentlyPlaying['videoUrl']);

                //close the popup
                Navigator.pop(context);

                //set the currentlyPlaying
                currentlyPlaying['audioUrl'] = audioUrl;
                myState.setCurrentlyPlaying(currentlyPlaying);
              },
            );
          },
        );
      },
    );
  }
}
