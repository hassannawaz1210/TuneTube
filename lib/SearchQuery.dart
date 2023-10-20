import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ResultTile.dart';
import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';


class SearchResults extends StatelessWidget {
  final String query;
  final Function metadataCallback;

  const SearchResults({required this.query, required this.metadataCallback});

  Future<List<Map<String, dynamic>>> searchVideos(String query) async {
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

//  Future<List<Map<String, dynamic>>> searchYouTube(String query) async {
    // final response = await http.get(Uri.parse(
    //   'https://www.googleapis.com/youtube/v3/search?'
    //   'part=snippet&type=video&q=$query&key=$apiKey&maxResults=20',
    // ));

    // if (response.statusCode == 200) {
    //   final Map<String, dynamic>? data = json.decode(response.body);
    //   if (data == null) {
    //     throw Exception('Failed to load videos');
    //   }

    //   final List<Map<String, dynamic>> videoItems = List.from(data['items']);
    //   return videoItems;
    // } else {
    //   throw Exception('Failed to load videos');
    // }

    //write to a file
    // final File file = File('lib/reponse.json');
    // await file.writeAsString(response.body);

    //read json file using i/o else throw exception
  //  try {
      //    final File file = File('lib/response.json');
      // final String response = await file.readAsString();
     // final String response = await searchVideos(query);
     // final Map<String, dynamic>? data = json.decode(response);
  //     if (data == null) {
  //       throw Exception('Failed to load videos');
  //     }

  //     final List<Map<String, dynamic>> videoItems = List.from(data['items']);
  //     return videoItems;
  //   } catch (e) {
  //     throw Exception('Failed to load videos');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: searchVideos(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found.'));
        } else {
          final videoItems = snapshot.data!;
          return ResultTile(
              videoItems: videoItems, metadataCallback: metadataCallback);
        }
      },
    );
  }
}
