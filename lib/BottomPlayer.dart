import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tunetube/AudioStream.dart';
import 'package:tunetube/MainPlayer2.dart';
import 'package:tunetube/PlaylistStateManagement.dart';

class BottomPlayer extends StatefulWidget {
  Map<String, dynamic>? currentVideo;
  List<Map<String, dynamic>>? searchResults;

  BottomPlayer({Key? key, this.currentVideo, this.searchResults})
      : super(key: key);

  @override
  _BottomPlayerState createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  late AudioPlayer _audioPlayer;
  late List<Map<String, dynamic>> _playlist;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playlist = [];
    _readPlaylist();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _readPlaylist() async {
    try {
      if (Platform.isAndroid) {
        // For Android, read the file from the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/playlist.txt');
        await _readFile(file);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop, read the file from the project directory
        final file = File('lib/playlist.txt');
        await _readFile(file);
      }
    } catch (e) {
      print('Failed to read playlist: $e');
    }
  }

  Future<void> _readFile(File file) async {
    if (await file.exists()) {
      final fileContent = await file.readAsString();
      final lines = LineSplitter.split(fileContent);
      _playlist.clear();
      _playlist = [];
      _playlist = lines
          .map((line) => jsonDecode(line))
          .cast<Map<String, dynamic>>()
          .toList();
      print("Playlist read.");
    }
  }

  void _setPlaylistasSource() async {
    List<AudioSource> audioSources = [];
    int i = 0;
    List<Map<String, dynamic>> playlistCopy = List.from(_playlist);
    for (var item in playlistCopy) {
      AudioSource source = AudioSource.uri(
        Uri.parse(item['audioUrl']),
        tag: MediaItem(
          id: (i++).toString(),
          title: item['title'],
          artist: item['author'],
          artUri: Uri.parse(item['thumbnails']),
        ),
      );
      audioSources.add(source);
    }

    await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: []));
    await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        initialIndex: 0,
        initialPosition: Duration.zero,
        preload: true);

    //_audioPlayer.setLoopMode(LoopMode.all);
  }

  void _updateCurrentVideo() {
    // Get the current index from the audio source
    final index = _audioPlayer.currentIndex;

    // Check if the index is not null and within the range of the playlist
    if (index != null && index >= 0 && index < _playlist.length) {
      // Get the item at the current index
      var item = _playlist[index];

      // Update the values of currentVideo
      widget.currentVideo = {
        'title': item['title'] ?? 'default_title',
        'author': item['author'] ?? 'default_author',
        'thumbnail': item['thumbnails'] ?? 'default_thumbnail',
      };
    }
  }

  @override
  didUpdateWidget(BottomPlayer oldWidget) {
    print("didUpdateWidgetEDDDDDDDDDDDDD");
    super.didUpdateWidget(oldWidget);
    if (widget.currentVideo != null) {
      if (widget.currentVideo != oldWidget.currentVideo) {
        _play();
      }
    }

    final value = context.watch<PlaylistStateManagement>();
    if (value.buttonPressed) {
      // _audioPlayer.stop();
      // _readPlaylist();
      // _setPlaylistasSource();
      // _updateCurrentVideo();
      // _audioPlayer.play();
    }
  }

  Future<void> _play() async {
    //stop current audio if playing
    if (_audioPlayer.playing) _audioPlayer.stop();

    //stop playlist if playing
    context.read<PlaylistStateManagement>().setButtonPressed(false);

    //clear playlist
    await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: []));

    //set current video as audio source
    await _audioPlayer.setAudioSource(
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
    final value = context.watch<PlaylistStateManagement>();
    if (value.buttonPressed) {
      _readPlaylist();
      if (_audioPlayer.playing && _playlist.isNotEmpty) {
        _audioPlayer.stop();
      }
      _setPlaylistasSource();
      _updateCurrentVideo();
      _audioPlayer.play();
      print("value CHANGED.");
    } else {
      //ISSUE: cant do this because the player will never start playing as the buttonPressed value is initially false
      // if (_audioPlayer.playing) _audioPlayer.pause();
    }

    //print("im player");
    if (widget.currentVideo == null) {
      return Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  //------------ MainPlayer ----------------
                  MaterialPageRoute(
                      builder: (context) => MainPlayer(
                            audioPlayer: _audioPlayer,
                          )),
                  //-------------
                );
              },
              // --------------- Bottom Player ----------------
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
                    leading: Padding(
                        padding: EdgeInsets.only(left: 10, top: 8),
                        child: Icon(Icons.music_note, color: Colors.white)),
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
                            )),
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
                        //incase thumbnail is not available, display error icon
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
                            onPressed: () {
                              if (_audioPlayer.playing) {
                                _audioPlayer.pause();
                              }
                            },
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
