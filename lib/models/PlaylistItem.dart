import 'package:hive/hive.dart';

part 'PlaylistItem.g.dart';

@HiveType(typeId: 0)
class PlaylistItem {

  @HiveField(0)
  final String title;
  @HiveField(1)
  final String author;
  @HiveField(2)
  final String thumbnails;
  @HiveField(3)
  String audioUrl;
  @HiveField(4)
  final String videoUrl;
 @HiveField(5)
  final String description;
  @HiveField(6)
  final String duration;

  PlaylistItem({
    required this.title,
    required this.author,
    required this.thumbnails,
    required this.videoUrl,
    required this.description,
    required this.duration,
    this.audioUrl = '',
  });
}