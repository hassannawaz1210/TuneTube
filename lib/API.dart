import 'dart:async';
import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// A message suitable for presenting in the search and player UI.
class YouTubeServiceException implements Exception {
  const YouTubeServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

Future<T> _request<T>(
  Future<T> Function(YoutubeExplode yt) action, {
  required Duration timeout,
  required String failureMessage,
}) async {
  final yt = YoutubeExplode();
  try {
    return await action(yt).timeout(timeout);
  } on YouTubeServiceException {
    rethrow;
  } on TimeoutException {
    throw const YouTubeServiceException(
      'YouTube took too long to respond. Please try again.',
    );
  } on SocketException {
    throw const YouTubeServiceException(
      'Could not connect to YouTube. Check your internet connection.',
    );
  } catch (_) {
    throw YouTubeServiceException(failureMessage);
  } finally {
    yt.close();
  }
}

Future<List<Map<String, dynamic>>> getSearchResults(String query) async {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) return [];
  return _request(
    (yt) async {
      final videoId = VideoId.parseVideoId(normalizedQuery);
      final Iterable<Video> videos = videoId != null
          ? [await yt.videos.get(videoId)]
          : await yt.search.search(normalizedQuery);
      return videos
          .map((video) => <String, dynamic>{
                'title': video.title,
                'author': video.author,
                'description': video.description,
                'duration': _formatDuration(video.duration),
                'thumbnails': video.thumbnails.highResUrl,
                'videoUrl': 'https://www.youtube.com/watch?v=${video.id.value}',
              })
          .toList();
    },
    timeout: const Duration(seconds: 25),
    failureMessage:
        'YouTube could not find this music. Check the link or try your search again.',
  );
}

/// Resolve at playback time: YouTube stream URLs expire and must not be reused
/// as permanent playlist identifiers.
Future<String> getAudioUrl(String url) {
  return _request(
    (yt) async {
      // Let the library select current clients and handle its fallback.
      final manifest = await yt.videos.streams.getManifest(url);
      if (manifest.audioOnly.isEmpty) {
        throw const YouTubeServiceException(
          'This video has no playable audio. Try another track.',
        );
      }
      // Prefer AAC in MP4 for broad Android decoder support.
      final mp4 = manifest.audioOnly
          .where((stream) => stream.container == StreamContainer.mp4)
          .toList();
      final stream = (mp4.isNotEmpty ? mp4 : manifest.audioOnly)
          .withHighestBitrate();
      return stream.url.toString();
    },
    timeout: const Duration(seconds: 40),
    failureMessage:
        'YouTube could not play this track. It may be restricted or unavailable. Try another track.',
  );
}

String _formatDuration(Duration? duration) {
  if (duration == null) return 'LIVE';
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  if (duration.inHours > 0) {
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '${duration.inHours}:$minutes:$seconds';
  }
  return '${duration.inMinutes}:$seconds';
}
