import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;

  Controls(
      {Key? key, required this.audioPlayer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              icon: const Icon(Icons.skip_previous_rounded),
              iconSize: 64.0,
              color: Colors.white,
              onPressed: () {
                audioPlayer.seekToPrevious().then((value) {
                 // updateCurrentVideo();
                });
              }),
          StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (!(playing ?? false)) {
                  return IconButton(
                    icon: const Icon(Icons.play_arrow_rounded),
                    iconSize: 64.0,
                    color: Colors.white,
                    onPressed: audioPlayer.play,
                  );
                } else if (processingState != ProcessingState.completed) {
                  return IconButton(
                    icon: const Icon(Icons.pause_rounded),
                    iconSize: 64.0,
                    color: Colors.white,
                    onPressed: audioPlayer.pause,
                  );
                } else {
                  return IconButton(
                    icon: Icon(Icons.play_arrow_rounded),
                    iconSize: 64.0,
                    color: Colors.white,
                    onPressed: () => audioPlayer.seek(Duration.zero, index: 0),
                  );
                }
              }),
          IconButton(
              icon: const Icon(Icons.skip_next_rounded),
              iconSize: 64.0,
              color: Colors.white,
              onPressed: () {
                audioPlayer.seekToNext().then((value) {
                 // updateCurrentVideo();
                });
              }),
        ]));
  }
}
