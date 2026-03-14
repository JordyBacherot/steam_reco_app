/// A lightweight representation of a game.
///
/// Used primarily for displaying game summaries in lists or carousels.
class GameModel {
  /// Unique identifier for the game.
  final String id;
  
  /// The display title of the game.
  final String title;
  
  /// Internal storage for the image URL.
  final String _imageUrl;

  const GameModel({
    required this.id,
    required this.title,
    required String imageUrl,
  }) : _imageUrl = imageUrl;

  /// Returns the game's capsule image URL.
  ///
  /// Falls back to a standard Steam capsule URL if the provided URL is 
  /// empty or a placeholder.
  String get imageUrl {
    if (_imageUrl.isEmpty || _imageUrl.contains('picsum.photos')) {
      return 'https://cdn.akamai.steamstatic.com/steam/apps/$id/capsule_231x87.jpg';
    }
    return _imageUrl;
  }
}
