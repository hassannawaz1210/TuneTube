import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunetube/API.dart';
import 'package:tunetube/PlayerController.dart';

void main() {
  test('only the most recent search can replace results', () async {
    final requests = <String, Completer<List<Track>>>{};
    final controller = PlayerController(searchTracks: (query) {
      final pending = Completer<List<Track>>();
      requests[query] = pending;
      return pending.future;
    });
    addTearDown(controller.dispose);

    final oldSearch = controller.search('first');
    final newSearch = controller.search(' second ');
    requests['second']!.complete([{'title': 'New result'}]);
    await newSearch;
    requests['first']!.complete([{'title': 'Old result'}]);
    await oldSearch;

    expect(controller.query, 'second');
    expect(controller.results!.single['title'], 'New result');
    expect(controller.searching, isFalse);
  });

  test('clearing a search invalidates pending responses', () async {
    final pending = Completer<List<Track>>();
    final controller = PlayerController(searchTracks: (_) => pending.future);
    addTearDown(controller.dispose);
    final request = controller.search('music');
    await controller.search('  ');
    pending.complete([{'title': 'Late result'}]);
    await request;
    expect(controller.results, isNull);
    expect(controller.query, isEmpty);
    expect(controller.searching, isFalse);
  });

  test('search failures recover on a subsequent search', () async {
    var fails = true;
    final controller = PlayerController(searchTracks: (_) async {
      if (fails) throw StateError('offline');
      return [];
    });
    addTearDown(controller.dispose);
    await controller.search('music');
    expect(controller.searchError, isNotNull);
    expect(controller.searching, isFalse);
    fails = false;
    await controller.search('music');
    expect(controller.searchError, isNull);
    expect(controller.results, isEmpty);
  });

  test('failed tracks remain retryable and resolve a fresh URL each time', () async {
    var resolutions = 0;
    var playerCreations = 0;
    final controller = PlayerController(
      resolveAudio: (_) async {
        resolutions++;
        throw StateError('unavailable');
      },
      playerFactory: () {
        playerCreations++;
        throw StateError('The native player should not be needed.');
      },
    );
    addTearDown(controller.dispose);
    await controller.playTrack({'title': 'Track', 'videoUrl': 'video'});
    expect(controller.loadingTrack, isFalse);
    expect(controller.playbackError, isNotNull);
    await controller.togglePlayback();
    expect(resolutions, 2);
    expect(playerCreations, 0);
  });

  test('stale stream resolution never creates a player or replaces latest state', () async {
    final oldStream = Completer<String>();
    var playerCreations = 0;
    final controller = PlayerController(
      resolveAudio: (url) => url == 'first'
          ? oldStream.future
          : Future<String>.error(StateError('unavailable')),
      playerFactory: () {
        playerCreations++;
        throw StateError('The native player should not be needed.');
      },
    );
    addTearDown(controller.dispose);
    final first = controller.playTrack({'videoUrl': 'first'});
    await controller.playTrack({'videoUrl': 'second'});
    oldStream.complete('https://example.com/audio');
    await first;
    expect(controller.currentTrack!['videoUrl'], 'second');
    expect(controller.playbackError, isNotNull);
    expect(playerCreations, 0);
  });

  test('completed playback restarts even while the player reports playing', () async {
    final audio = _FakePlayer();
    var resolutions = 0;
    final controller = PlayerController(
      resolveAudio: (_) async {
        resolutions++;
        return 'https://example.com/audio';
      },
      playerFactory: () => audio,
    );
    addTearDown(controller.dispose);
    await controller.playTrack({'videoUrl': 'first'});
    audio.processingState = ProcessingState.completed;
    expect(audio.playing, isTrue);
    await controller.togglePlayback();
    expect(resolutions, 2);
    expect(audio.playCalls, 2);
  });

  test('dismissing a failed-track error cannot resume the preceding source', () async {
    final audio = _FakePlayer();
    var secondRequests = 0;
    final controller = PlayerController(
      resolveAudio: (url) async {
        if (url == 'second') {
          secondRequests++;
          throw const YouTubeServiceException('Track is restricted.');
        }
        return 'https://example.com/audio';
      },
      playerFactory: () => audio,
    );
    addTearDown(controller.dispose);
    await controller.playTrack({'videoUrl': 'first'});
    await controller.playTrack({'videoUrl': 'second'});
    expect(controller.playbackError, 'Track is restricted.');
    controller.clearPlaybackError();
    await controller.togglePlayback();
    expect(secondRequests, 2);
    expect(audio.playCalls, 1);
    expect(audio.playing, isFalse);
  });

  test('search preserves the service error message', () async {
    final controller = PlayerController(searchTracks: (_) async {
      throw const YouTubeServiceException('YouTube took too long to respond.');
    });
    addTearDown(controller.dispose);
    await controller.search('music');
    expect(controller.searchError, 'YouTube took too long to respond.');
  });

}


class _FakePlayer implements AudioPlayer {
  @override
  bool playing = false;
  @override
  ProcessingState processingState = ProcessingState.idle;
  int playCalls = 0;

  @override
  Stream<PlayerState> get playerStateStream => const Stream.empty();

  @override
  Future<void> pause() async { playing = false; }

  @override
  Future<void> stop() async { playing = false; }

  @override
  Future<void> play() async {
    playCalls++;
    playing = true;
  }

  @override
  Future<Duration?> setAudioSource(AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    processingState = ProcessingState.ready;
    return const Duration(minutes: 3);
  }

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
