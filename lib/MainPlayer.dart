import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class MainPlayer extends StatefulWidget {
  final Map<String, dynamic> metadata;
  final AudioPlayer _audioPlayer;
  final Duration initialDuration;
  final Duration initialPosition;

  MainPlayer({
    Key? key,
    required this.metadata,
    required AudioPlayer audioPlayer,
    required this.initialDuration,
    required this.initialPosition,
  })  : _audioPlayer = audioPlayer,
        super(key: key);

  @override
  _MainPlayerState createState() => _MainPlayerState();
}

class _MainPlayerState extends State<MainPlayer> {
  Duration _duration = const Duration();
  Duration _position = const Duration();
  late StreamSubscription<Duration> _durationSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<PlayerState> _playerStateSubscription;

  double _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();

    _duration = widget.initialDuration;
    _position = widget.initialPosition;
    _durationSubscription =
        widget._audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });
    _positionSubscription =
        widget._audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
        _currentPosition = p.inSeconds.toDouble();
      });
    });
    _playerStateSubscription =
        widget._audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        setState(() {
          _position = _duration;
        });
      }
    });
    // widget._audioPlayer.stop();
    //widget._audioPlayer.setSourceUrl(widget.metadata['audioUrl']);
  }

  @override
  void dispose() {
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _playerStateSubscription.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? twoDigits(duration.inHours) + ":" : ""}$twoDigitMinutes:$twoDigitSeconds";
  }

  // Future<void> loadThumbnail() async {
  //   if (widget.musicInfo['thumbnail'] == null) {
  //    await Image.network(
  //       'https://i.ytimg.com/vi/5qap5aO4i9A/maxresdefault.jpg',
  //     );
  //   }

  //   else
  //   {
  //     await Image.network(widget.musicInfo['thumbnail']);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  //back button
                  Positioned(
                    top: 20,
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //thumbnail image
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 50.0,
                          right: 50.0,
                          bottom: 15.0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.metadata['thumbnail'] ??
                                'https://i.ytimg.com/vi/5qap5aO4i9A/maxresdefault.jpg',
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, color: Colors.white),
                          ),
                        ),
                      ),
                      //title text
                      Text(
                        widget.metadata['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      //author text
                      Text(
                        widget.metadata['author'],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'JosefinSans'),
                      ),
                      SizedBox(height: 16),
                      //slider
                      Padding(
                          padding:
                              const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Slider(
                            value: _position.inSeconds.toDouble(),
                            min: 0,
                            max: _duration.inSeconds.toDouble(),
                            onChanged: (double value) {
                              setState(() {
                                widget._audioPlayer
                                    .seek(Duration(seconds: value.toInt()));
                              });
                            },
                          )),
                      //timer
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(
                                  Duration(seconds: _currentPosition.toInt())),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(Duration(
                                  seconds: _duration.inSeconds.toInt())),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      //buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous),
                            onPressed: () {},
                            color: Colors.white,
                          ),
                          IconButton(
                            icon: Icon(
                                widget._audioPlayer.state == PlayerState.playing
                                    ? Icons.pause
                                    : Icons.play_arrow),
                            onPressed: () {
                              if (widget._audioPlayer.state ==
                                  PlayerState.playing) {
                                widget._audioPlayer.pause();
                              } else {
                                widget._audioPlayer.resume();
                              }
                            },
                            color: Colors.white,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next),
                            onPressed: () {},
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }
}
