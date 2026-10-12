import 'dart:async';
import 'dart:io';

import '../lib/API.dart';

/// Live integration smoke check: dart run tool/youtube_probe.dart [video URL].
Future<void> main(List<String> args) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final results = await getSearchResults('acoustic guitar instrumental');
    if (results.isEmpty) throw StateError('Search returned no videos.');
    stdout.writeln('PASS search: ${results.length} videos');
    final video = args.isNotEmpty
        ? args.first
        : results.first['videoUrl'] as String;
    final directResults = await getSearchResults(video);
    if (directResults.length != 1) {
      throw StateError('Direct video lookup did not return one video.');
    }
    stdout.writeln('PASS direct video lookup');
    final url = await getAudioUrl(video);
    stdout.writeln('PASS audio manifest: resolved an audio stream');
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-1023');
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != 200 && response.statusCode != 206) {
      throw HttpException('Audio returned HTTP ${response.statusCode}');
    }
    final chunk = await response.first.timeout(const Duration(seconds: 20));
    if (chunk.isEmpty) throw StateError('Audio response was empty.');
    stdout.writeln('PASS audio delivery: received ${chunk.length} bytes');
  } catch (error) {
    stderr.writeln('FAIL YouTube integration: $error');
    exitCode = 1;
  } finally {
    client.close(force: true);
  }
}
