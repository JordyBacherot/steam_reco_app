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

  /// Number of hours played (optional, usually from library).
  final int? hours;

  const GameModelDetailed({
    required this.idGame,
    required this.name,
    this.description,
    String? imageUrl,
    this.studio,
    this.meanReview,
    this.hours,
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
    // If the data is nested in a 'game' key (typical for library records), use that.
    final Map<String, dynamic> gameData = json['game'] is Map<String, dynamic> 
        ? json['game'] as Map<String, dynamic> 
        : json;

    return GameModelDetailed(
      idGame: int.parse(gameData['id_game'].toString()),
      name: (gameData['name'] ?? gameData['game_title'] ?? '') as String,
      description: gameData['description'] as String?,
      imageUrl: (gameData['image_url'] ?? gameData['game_image_url']) as String?,
      studio: gameData['studio'] as String?,
      meanReview: gameData['mean_review'] != null 
          ? double.tryParse(gameData['mean_review'].toString())
          : null,
      hours: json['nb_hours'] != null ? int.tryParse(json['nb_hours'].toString()) : null,
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
      'nb_hours': hours,
    };
  }
}
