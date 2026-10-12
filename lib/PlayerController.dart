import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'API.dart';

typedef Track = Map<String, dynamic>;
typedef SearchTracks = Future<List<Track>> Function(String query);
typedef ResolveAudio = Future<String> Function(String videoUrl);

/// Owns discovery and a single audio player for every screen.
class PlayerController extends ChangeNotifier {
  PlayerController({
    SearchTracks? searchTracks,
    ResolveAudio? resolveAudio,
    AudioPlayer Function()? playerFactory,
  })  : _searchTracks = searchTracks ?? getSearchResults,
        _resolveAudio = resolveAudio ?? getAudioUrl,
        _playerFactory = playerFactory ?? AudioPlayer.new;

  final SearchTracks _searchTracks;
  final ResolveAudio _resolveAudio;
  final AudioPlayer Function() _playerFactory;
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _stateSubscription;
  Future<void> _sourceChanges = Future<void>.value();
  int _searchGeneration = 0;
  int _playGeneration = 0;
  int? _loadedGeneration;
  bool _disposed = false;

  List<Track>? results;
  String query = '';
  bool searching = false;
  String? searchError;
  Track? currentTrack;
  bool loadingTrack = false;
  String? playbackError;
  List<Track> queue = [];
  int queueIndex = -1;
  bool repeat = false;

  bool get hasPlayableSource =>
      !_disposed && !loadingTrack && _loadedGeneration == _playGeneration;

  AudioPlayer get player {
    if (_disposed) throw StateError('PlayerController has been disposed.');
    if (_player != null) return _player!;
    final audio = _playerFactory();
    _player = audio;
    _stateSubscription = audio.playerStateStream.listen((state) {
      if (_disposed) return;
      if (state.processingState == ProcessingState.completed &&
          !loadingTrack &&
          _loadedGeneration == _playGeneration &&
          playbackError == null) {
        if (repeat && currentTrack != null) {
          unawaited(playTrack(currentTrack!));
        } else if (queueIndex >= 0 && queueIndex + 1 < queue.length) {
          unawaited(next());
        }
      }
      _notify();
    });
    return audio;
  }

  Future<void> search(String value) async {
    final generation = ++_searchGeneration;
    query = value.trim();
    searchError = null;
    if (query.isEmpty) {
      searching = false;
      results = null;
      _notify();
      return;
    }
    searching = true;
    results = null;
    _notify();
    try {
      final found = await _searchTracks(query);
      if (_disposed || generation != _searchGeneration) return;
      results = found;
    } catch (error) {
      if (_disposed || generation != _searchGeneration) return;
      searchError = error is YouTubeServiceException
          ? error.message
          : 'Could not reach YouTube. Check your connection and try again.';
    } finally {
      if (!_disposed && generation == _searchGeneration) {
        searching = false;
        _notify();
      }
    }
  }

  Future<void> playTrack(Track track, {List<Track>? tracks}) async {
    if (_disposed) return;
    final generation = ++_playGeneration;
    if (tracks != null) queue = List<Track>.of(tracks);
    queueIndex = queue.indexWhere((item) => item['videoUrl'] == track['videoUrl']);
    if (queueIndex < 0) {
      queue = [track];
      queueIndex = 0;
    }
    currentTrack = track;
    loadingTrack = true;
    playbackError = null;
    _notify();

    // Resolve afresh: YouTube media URLs expire and must never be persisted.
    try {
      if (_player != null) await _player!.pause();
      if (_disposed || generation != _playGeneration) return;
      final videoUrl = track['videoUrl']?.toString() ?? '';
      if (videoUrl.isEmpty) throw StateError('Missing video URL.');
      final url = await _resolveAudio(videoUrl);
      if (_disposed || generation != _playGeneration) return;
      if (url.isEmpty) throw StateError('No playable stream was returned.');
      // Only one setAudioSource may be in flight, even after rapid track taps.
      final change = _sourceChanges.then((_) async {
        if (_disposed || generation != _playGeneration) return;
        final audio = player;
        await audio.stop();
        if (_disposed || generation != _playGeneration) return;
        final artwork = Uri.tryParse(track['thumbnails']?.toString() ?? '');
        await audio.setAudioSource(AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: videoUrl,
            title: track['title']?.toString() ?? 'Untitled',
            artist: track['author']?.toString() ?? 'YouTube',
            artUri: artwork != null && artwork.hasScheme ? artwork : null,
          ),
        ));
        if (_disposed || generation != _playGeneration) return;
        _loadedGeneration = generation;
        loadingTrack = false;
        _notify();
        unawaited(_startPlayback(audio, generation));
      });
      // Keep the serialization chain usable after an individual source fails.
      _sourceChanges = change.catchError((Object _) {});
      await change;
    } catch (error) {
      if (_disposed || generation != _playGeneration) return;
      playbackError = error is YouTubeServiceException
          ? error.message
          : 'This track could not be played. Try again or choose another track.';
    } finally {
      if (!_disposed && generation == _playGeneration) {
        loadingTrack = false;
        _notify();
      }
    }
  }

  Future<void> _startPlayback(AudioPlayer audio, int generation) async {
    try {
      await audio.play();
    } catch (_) {
      if (_disposed || generation != _playGeneration) return;
      _loadedGeneration = null;
      playbackError = 'Playback stopped. Check your connection and try again.';
      _notify();
    }
  }

  Future<void> next() async {
    if (queue.isEmpty || queueIndex + 1 >= queue.length) return;
    await playTrack(queue[queueIndex + 1]);
  }

  Future<void> previous() async {
    if (loadingTrack || _disposed) return;
    if (_loadedGeneration == _playGeneration &&
        _player != null && player.position > const Duration(seconds: 3)) {
      await player.seek(Duration.zero);
    } else if (queueIndex > 0) {
      await playTrack(queue[queueIndex - 1]);
    } else if (_loadedGeneration == _playGeneration && _player != null) {
      await player.seek(Duration.zero);
    }
  }

  Future<void> togglePlayback() async {
    if (_disposed || currentTrack == null || loadingTrack) return;
    if (_loadedGeneration != _playGeneration ||
        playbackError != null ||
        _player == null ||
        player.processingState == ProcessingState.completed) {
      await playTrack(currentTrack!);
    } else if (player.playing) {
      await player.pause();
    } else {
      unawaited(_startPlayback(player, _playGeneration));
    }
  }

  Future<void> toggleRepeat() async {
    repeat = !repeat;
    _notify();
  }

  void clearPlaybackError() {
    playbackError = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchGeneration++;
    _playGeneration++;
    unawaited(_stateSubscription?.cancel());
    unawaited(_player?.dispose());
    super.dispose();
  }
}
