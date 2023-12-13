import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

import 'Controls.dart';
import 'MediaMetadata.dart';
import 'PositionData.dart';

class MainPlayer extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const MainPlayer({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _MainPlayerState createState() => _MainPlayerState();
}

class _MainPlayerState extends State<MainPlayer> {

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          widget.audioPlayer.positionStream,
          widget.audioPlayer.bufferedPositionStream,
          widget.audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
                position: position,
                bufferedPosition: bufferedPosition,
                duration: duration ?? Duration.zero,
              ));

  @override
  void initState() {
    super.initState();
   // _init();
  }

  // Future<void> _init() async {
  //   // await widget.audioPlayer.setAudioSource(_playlist);
  //   await widget.audioPlayer.setLoopMode(LoopMode.all);


  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      //alignment: Alignment.center,
      color: Colors.black,
      child: Column(children: [
        StreamBuilder(
          stream: widget.audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state?.sequence.isEmpty ?? true)
            {
              return const MediaMetadata(
                title: 'Unknown',
                artist: 'Unknown',
                imageUrl: 'displayLogo',
              );
            }
            final metadata = state?.currentSource?.tag as MediaItem?;
            return MediaMetadata(
              title: metadata?.title ?? '',
              artist: metadata?.artist ?? '',
              imageUrl: metadata?.artUri.toString() ?? '',
            );
          },
        ),
        const SizedBox(
          height: 50,
        ),
        //MediaMetadata
        StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: ProgressBar(
                    //styling
                    thumbColor: Colors.red,
                    barHeight: 8,
                    baseBarColor: Colors.grey[600],
                    bufferedBarColor: Colors.grey,
                    progressBarColor: Colors.red,
                    timeLabelTextStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    //
                    progress: positionData?.position ?? Duration.zero,
                    buffered: positionData?.bufferedPosition ?? Duration.zero,
                    total: positionData?.duration ?? Duration.zero,
                    onSeek: (duration) {
                      widget.audioPlayer.seek(duration);
                    },
                  ));
            }),
        const SizedBox( height: 20,),
        Controls(audioPlayer: widget.audioPlayer),
      ]),
    ));
  }
}
