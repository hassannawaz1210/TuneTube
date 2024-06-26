import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tunetube/API.dart';
import 'package:tunetube/Boxes.dart';
import 'package:tunetube/MyState.dart';
import 'MySnackbar.dart';

class PlaylistDrawer extends StatefulWidget {
  PlaylistDrawer({Key? key}) : super(key: key);

  @override
  _PlaylistDrawerState createState() => _PlaylistDrawerState();
}

class _PlaylistDrawerState extends State<PlaylistDrawer> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Drawer(
            child: ValueListenableBuilder<Box>(
              valueListenable: Boxes.getPlaylist().listenable(),
              builder: (context, Box playlistBox, child) {
                final playlist = playlistBox.values.toList();
                if (playlist.isEmpty) {
                  return const Center(
                      child: Text(
                    "Your playlist is empty",
                    style: TextStyle(color: Colors.white),
                  ));
                }
                return Column(children: [
                  //======= head
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 1.0, // Border width
                        
                      ),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              'Playlist',
                              style: TextStyle(color: Colors.white),
                            )),
                        const Spacer(),
                        IconButton(
                          icon: _isPlaying
                              ? const Icon(Icons.pause, color: Colors.white)
                              : const Icon(Icons.play_arrow, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isPlaying = !_isPlaying;
                            });
                            if (_isPlaying) {
                              Provider.of<MyState>(context, listen: false)
                                  .setCurrentlyPlaying(playlist);
                            } else {
                              Provider.of<MyState>(context, listen: false)
                                  .setCurrentlyPlaying(null);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  //======== body
                  Expanded(
                      child: ListView.builder(
                          itemCount: playlist.length,
                          itemBuilder: (context, index) {
                            final item = playlist[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(
                                    color: Colors.white, width: 1.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: ListTile(
                                leading: CachedNetworkImage(
                                    imageUrl: item.thumbnails,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error, color: Colors.white),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          height: 50.0,
                                          width: 50.0,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        )),
                                title: Text(item.title , style: TextStyle(color: Colors.white)),
                                subtitle: Text(item.author,style: TextStyle(color: Colors.white)),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        MySnackbar.show('Deleted from playlist.'));
                                    playlistBox.deleteAt(index);
                                  },
                                ),
                                onTap: () {
                                  if (item.audioUrl == null || item.audioUrl == '') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        MySnackbar.show(
                                            'Audio url not available. Trying to fetch again...'));
                                    //Asynchronously Fetch the audioUrl for the playlist item
                                    getAudioUrl(item.videoUrl).then((audioUrl) {
                                      item.audioUrl = audioUrl;
                                      playlistBox.putAt(index, item);
                                      print("audio url fetched successfully.");
                                    }).catchError((error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          MySnackbar.show(
                                              'Couldnt fetch the audioUrl for the playlist item.'));
                                      print('Error: ');
                                    });
                                    return;
                                  }
                                    final Map<String, dynamic>? selectedItem = {
                                    'title': item.title,
                                    'author': item.author,
                                    'description': item.description,
                                    'duration': item.duration,
                                    'thumbnails': item.thumbnails,
                                    'videoUrl': item.videoUrl,
                                    'audioUrl': item.audioUrl ?? ''
                                  };
                                  Provider.of<MyState>(context, listen: false)
                                      .setCurrentlyPlaying(selectedItem!);
                                },
                              )
                            );
                          }))
                ]);
              },
            ),
          )
        )
      ),
    );
  }
}
