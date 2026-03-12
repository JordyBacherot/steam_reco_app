class GameModel {
  final String id;
  final String title;
  final String _imageUrl;

  const GameModel({
    required this.id,
    required this.title,
    required String imageUrl,
  }) : _imageUrl = imageUrl;

  String get imageUrl {
    if (_imageUrl.isEmpty || _imageUrl.contains('picsum.photos')) {
      return 'https://cdn.akamai.steamstatic.com/steam/apps/$id/capsule_231x87.jpg';
    }
    return _imageUrl;
  }
}
