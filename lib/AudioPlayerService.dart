import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static AudioPlayer? _audioPlayer;

  static AudioPlayer get audioPlayer {
    _audioPlayer ??= AudioPlayer();
    return _audioPlayer!;
  }

  static void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
  }
}