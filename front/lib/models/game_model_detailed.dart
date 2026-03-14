/// A comprehensive data model representing detailed game information.
///
/// Used for display on detail pages and within the user's library.
class GameModelDetailed {
  /// Unique database identifier for the game.
  final int idGame;

  /// The official name of the game.
  final String name;

  /// A descriptive summary of the game.
  final String? description;

  /// The average review score (ranging from 0.0 to 1.0).
  final double? meanReview;

  /// Internal storage for the image URL.
  final String _imageUrl;

  /// The studio that developed the game.
  final String? studio;

  const GameModelDetailed({
    required this.idGame,
    required this.name,
    this.description,
    String? imageUrl,
    this.studio,
    this.meanReview,
  }) : _imageUrl = imageUrl ?? '';

  /// Returns the game's capsule image URL.
  ///
  /// Automatically generates a Steam CDN URL based on the [idGame] if no 
  /// valid URL is provided.
  String get imageUrl {
    if (_imageUrl.isEmpty || _imageUrl.contains('picsum.photos')) {
      return 'https://cdn.akamai.steamstatic.com/steam/apps/$idGame/capsule_231x87.jpg';
    }
    return _imageUrl;
  }

  /// Creates a [GameModelDetailed] instance from a JSON map.
  factory GameModelDetailed.fromJson(Map<String, dynamic> json) {
    return GameModelDetailed(
      idGame: int.parse(json['id_game'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      studio: json['studio'] as String?,
      meanReview: json['mean_review'] != null 
          ? double.tryParse(json['mean_review'].toString())
          : null,
    );
  }

  /// Serializes the model into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id_game': idGame,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'studio': studio,
      'mean_review': meanReview,
    };
  }
}
