import 'package:hive/hive.dart';
import 'package:tunetube/models/PlaylistItem.dart';

class Boxes {
  static Box<PlaylistItem> getPlaylist() =>
      Hive.box<PlaylistItem>('playlist');
}