import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tunetube/AudioPlayerService.dart';
import 'package:tunetube/MainPlayer.dart';
import 'package:tunetube/MyState.dart';
import 'package:just_audio/just_audio.dart';

enum Direction { left, right }

class BottomPlayer extends StatefulWidget {
  @override
  _BottomPlayerState createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayerService.audioPlayer;

  void initState() {
    super.initState();
    //!todo: add loop button
    _audioPlayer.setLoopMode(LoopMode.off);
  }

  void stopOldPlayNew() async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.play();
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void setAudioSource(dynamic currentlyPlaying) async {
    if (currentlyPlaying is Map<String, dynamic>) //if single item
    {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(currentlyPlaying['audioUrl']),
          tag: MediaItem(
            id: '0',
            title: currentlyPlaying['title'],
            artist: currentlyPlaying['author'],
            artUri: Uri.parse(currentlyPlaying['thumbnails']),
          ),
        ),
      );
    } else if (currentlyPlaying is List<dynamic>) //if playlist
    {
      final List<AudioSource> _audioSources = [];
      int i = 0;

      _audioSources.clear();
      for (var item in currentlyPlaying) {
        AudioSource source = AudioSource.uri(
          Uri.parse(item.audioUrl),
          tag: MediaItem(
            id: (i++).toString(),
            title: item.title,
            artist: item.author,
            artUri: Uri.parse(item.thumbnails),
          ),
        );
        _audioSources.add(source);
      }
      print("THIS is currently played LENTHHHHHH");
      print(currentlyPlaying.length);
      print("THIS IS AUDIO SOURCES LENTHHHHHH");
      print(_audioSources.length);
      if (_audioSources.isNotEmpty) {
        await _audioPlayer.setAudioSource(
          ConcatenatingAudioSource(
            children: _audioSources,
            useLazyPreparation: true,
          ),
          initialIndex: 0,
          initialPosition: Duration.zero,
          preload: true,
        );
      }
    }
  }

  void onSwipe(Direction direction) {
    if (direction == Direction.left) {
      _audioPlayer.seekToNext();
    } else {
      _audioPlayer.seekToPrevious();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("this is bottom player");

    return Selector<MyState, dynamic>(
      selector: (_, model) => model.currentlyPlaying,
      builder: (context, currentlyPlaying, child) {
        final _currentlyPlaying = currentlyPlaying;

        if (_currentlyPlaying != null) {
          setAudioSource(_currentlyPlaying);
          //stop the currently playing audio, if any
          stopOldPlayNew();
          // print("audioUrl: ${_currentlyPlaying['audioUrl']}");
        } else {
          _audioPlayer.stop();
        }

        return _currentlyPlaying != null
            ? Padding(
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
                                    )),
                          );
                        },
                        child: StreamBuilder(
                          stream: Rx.combineLatest2(
                            _audioPlayer.playerStateStream,
                            _audioPlayer.sequenceStateStream,
                            (PlayerState playerState,
                                    SequenceState? sequenceState) =>
                                {
                              'playerState': playerState,
                              'tag': sequenceState?.currentSource?.tag
                            },
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            final data = snapshot.data as Map;
                            final PlayerState playerState = data['playerState'];
                            final processingState = playerState.processingState;
                            final playing = playerState.playing;
                            final metadata = data['tag'];

                               return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! > 0) {
          // Swipe Right
          onSwipe(Direction.right);
        } else if (details.primaryVelocity! < 0) {
          // Swipe Left
          onSwipe(Direction.left);
        }
      },
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                tileColor: Colors.black,
                                leading: Image.network(
                                  metadata.artUri.toString() ?? '',
                                  errorBuilder: (context, url, error) =>
                                      const Padding(
                                          padding:
                                              EdgeInsets.only(left: 10, top: 5),
                                          child: Icon(Icons.error,
                                              color: Colors.white)),
                                ),
                                title: Text(metadata.title ?? 'Unknown',
                                    style: const TextStyle(color: Colors.white)),
                                subtitle: Text(metadata.artist ?? 'Unknown',
                                    style: const TextStyle(color: Colors.white)),
                                trailing: !(playing ?? false)
                                    ? IconButton(
                                        icon:
                                            const Icon(Icons.play_arrow_rounded),
                                        color: Colors.white,
                                        onPressed: _audioPlayer.play,
                                      )
                                    : processingState != ProcessingState.completed
                                        ? IconButton(
                                            icon: const Icon(Icons.pause_rounded),
                                            color: Colors.white,
                                            onPressed: () {
                                              if (_audioPlayer.playing) {
                                                _audioPlayer.pause();
                                              }
                                            },
                                          )
                                        : IconButton(
                                            icon: const Icon(
                                                Icons.play_arrow_rounded),
                                            color: Colors.white,
                                            onPressed: () => _audioPlayer
                                                .seek(Duration.zero, index: 0),
                                          ),
                              )
                            );
                          },
                        ))),
              )
            : Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   // Navigation logic here
                      // );
                    },
                    child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          title: Text('Now Playing',
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text('Unknown',
                              style: TextStyle(color: Colors.white)),
                          leading: Padding(
                              padding: EdgeInsets.only(left: 10, top: 8),
                              child:
                                  Icon(Icons.music_note, color: Colors.white)),
                          trailing: Icon(Icons.play_arrow, color: Colors.white),
                          tileColor: Colors.black,
                        ))));
      },
    );
  }
}
