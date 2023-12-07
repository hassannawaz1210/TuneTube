import 'dart:async';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<String> getAudioUrl(String url) async {
  final yt = YoutubeExplode();
  var audioUrl = '';

  try {
    var manifest = await yt.videos.streamsClient.getManifest(url);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    audioUrl = streamInfo.url.toString();
  } catch (e) {
    print('Failed to get audio URL: $e');
  } finally {
    yt.close();
  }

  return audioUrl;
}



// Future<String> searchVideos(String query) async {
//   final yt = YoutubeExplode();
//   var searchResults = await yt.search.getVideos(query);
//   var jsonResults = searchResults.map((video) => {
//     'title': video.title,
//     'author': video.author,
//     'description': video.description,
//     'duration': video.duration.toString(),
//     'thumbnails': video.thumbnails.standardResUrl,
//   }).toList();
//   yt.close();

//   return jsonEncode(jsonResults);
// }