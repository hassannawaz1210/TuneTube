import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tunetube/MainPlayer.dart';

class BottomPlayer extends StatefulWidget {
  final Map<String, dynamic>? metadata;
  List<Map<String, dynamic>>? searchResults;

  BottomPlayer({Key? key, this.metadata, this.searchResults}) : super(key: key);

  @override
  _BottomPlayerState createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  late AudioPlayer _audioPlayer;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });
    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  didUpdateWidget(BottomPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.metadata != null) {
      //
      if (widget.metadata != oldWidget.metadata) {
        _play();
      }
    }
  }

  Future<void> _play() async {
    if (widget.metadata == null) {
      return;
    }

    print(widget.metadata!['audioUrl']!);
    await _audioPlayer.setSourceUrl((widget.metadata!['audioUrl']!));
    await _audioPlayer.play(UrlSource(widget.metadata!['audioUrl']!));
  }

  Future<void> _pause() async {
    await _audioPlayer.pause();
  }

  Future<void> _resume() async {
    await _audioPlayer.resume();
  }

  @override
  Widget build(BuildContext context) {
    //print("im player");
    if (widget.metadata == null) {
      return Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainPlayer(
                            //send dummy data to
                            metadata: const {
                              'title': 'Unknown',
                              'author': 'Unknown',
                              'thumbnail':
                                  'https://i.ytimg.com/vi/5qap5aO4i9A/maxresdefault.jpg',
                              'audioUrl': 'url'
                            },
                            audioPlayer: AudioPlayer(),
                            initialDuration: const Duration(),
                            initialPosition: const Duration(),
                          )),
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
                              metadata: widget.metadata as Map<String, dynamic>,
                              audioPlayer: _audioPlayer,
                              initialDuration: _duration,
                              initialPosition: _position,
                            )),
                  );
                },
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  tileColor: Colors.black,
                  leading: Image.network(
                    widget.metadata!['thumbnail'],
                    errorBuilder: (context, url, error) => const Padding(
                        padding: EdgeInsets.only(left: 10, top: 5),
                        child: Icon(Icons.error, color: Colors.white)),
                  ),
                  title: Text(widget.metadata!['title'],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(widget.metadata!['author'],
                      style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: Icon(
                        _audioPlayer.state == PlayerState.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white),
                    onPressed: () {
                      if (_audioPlayer.state == PlayerState.playing) {
                        _pause();
                      } else {
                        _play();
                      }
                    },
                  ),
                ))));
  }
}
