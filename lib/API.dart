import 'package:youtube_explode_dart/youtube_explode_dart.dart';

  Future<List<Map<String, dynamic>>> getSearchResults(String query) async {
    final yt = YoutubeExplode();
    var searchResults = await yt.search(query);
    var jsonResults = searchResults
        .map((video) => {
              'title': video.title,
              'author': video.author,
              'description': video.description,
              'duration': video.duration.toString(),
              'thumbnails': video.thumbnails.standardResUrl,
              'videoUrl': 'https://www.youtube.com/watch?v=${video.id.value}',
            })
        .toList();
    yt.close();
    return jsonResults;
  }

  
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


  //// also import playlilstItem.dart
  // Future<List<PlaylistItem>> getSearchResults(String query) async {
  //   final yt = YoutubeExplode();
  //   var searchResults = await yt.search(query);
  //   var searchList = searchResults
  //       .map((video) =>
  //       PlaylistItem(
  //         title: video.title,
  //         author: video.author,
  //         description: video.description,
  //         duration: video.duration.toString(),
  //         thumbnails: video.thumbnails.standardResUrl,
  //         videoUrl: 'https://www.youtube.com/watch?v=${video.id.value}',
  //       ))
  //       .toList();
  //   yt.close();
  //   return searchList;
  // }
