

class MetadataProvider with ChangeNotifier {
  Map<String, dynamic> _metadata;

  Map<String, dynamic> get metadata => _metadata;

  void setMetadata(Map<String, dynamic> newMetadata) {
    _metadata = newMetadata;
    notifyListeners();
  }
}