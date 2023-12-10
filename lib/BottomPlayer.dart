import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tunetube/MainPlayer2.dart';

class BottomPlayer extends StatefulWidget {
  final Map<String, dynamic>? currentVideo;
  List<Map<String, dynamic>>? searchResults;

  BottomPlayer({Key? key, this.currentVideo, this.searchResults})
      : super(key: key);

  @override
  _BottomPlayerState createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  didUpdateWidget(BottomPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentVideo != null) {
      //
      if (widget.currentVideo != oldWidget.currentVideo) {
        _play();
      }
    }
  }

  Future<void> _play() async {

    _audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(widget.currentVideo!['audioUrl']),
        tag: MediaItem(
          id: '0',
          title: widget.currentVideo!['title'],
          artist: widget.currentVideo!['author'],
          artUri: Uri.parse(widget.currentVideo!['thumbnail']),
        ),
      ),
    );
    _audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    //print("im player");
    if (widget.currentVideo == null) {
      return Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainPlayer(
                            audioPlayer: _audioPlayer,
                            currentVideo: widget.currentVideo!,
                          )
                      // MainPlayer(
                      //       //send dummy data to
                      //       metadata: const {
                      //         'title': 'Unknown',
                      //         'author': 'Unknown',
                      //         'thumbnail':
                      //             'https://i.ytimg.com/vi/5qap5aO4i9A/maxresdefault.jpg',
                      //         'audioUrl': 'url'
                      //       },
                      //       audioPlayer: AudioPlayer(),
                      //       initialDuration: const Duration(),
                      //       initialPosition: const Duration(),
                      //     )
                      ),
                );
              },
              child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    title: Text('Now Playing',
                        style: TextStyle(color: Colors.white)),
                    subtitle:
                        Text('Unknown', style: TextStyle(color: Colors.white)),
                    leading: Icon(Icons.music_note, color: Colors.white),
                    trailing: Icon(Icons.play_arrow, color: Colors.white),
                    tileColor: Colors.black,
                  ))));
    }

    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainPlayer(
                              audioPlayer: _audioPlayer,
                              currentVideo: widget.currentVideo!,
                            )
                        // MainPlayer(
                        //       metadata: widget.metadata as Map<String, dynamic>,
                        //       audioPlayer: _audioPlayer,
                        //       initialDuration: _duration,
                        //       initialPosition: _position,
                        //     )
                        ),
                  );
                },
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  tileColor: Colors.black,
                  leading: Image.network(
                    widget.currentVideo!['thumbnail'],
                    errorBuilder: (context, url, error) => const Padding(
                        padding: EdgeInsets.only(left: 10, top: 5),
                        child: Icon(Icons.error, color: Colors.white)),
                  ),
                  title: Text(widget.currentVideo!['title'],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(widget.currentVideo!['author'],
                      style: const TextStyle(color: Colors.white)),
                  trailing: StreamBuilder<PlayerState>(
                      stream: _audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;

                        if (!(playing ?? false)) {
                          return IconButton(
                            icon: const Icon(Icons.play_arrow_rounded),
                            color: Colors.white,
                            onPressed: _audioPlayer.play,
                          );
                        } else if (processingState !=
                            ProcessingState.completed) {
                          return IconButton(
                            icon: const Icon(Icons.pause_rounded),
                            color: Colors.white,
                            onPressed: _audioPlayer.pause,
                          );
                        }
                        return IconButton(
                          icon: const Icon(Icons.play_arrow_rounded),
                          color: Colors.white,
                          onPressed: () =>
                              _audioPlayer.seek(Duration.zero, index: 0),
                        );
                      }),
                ))));
  }
}
