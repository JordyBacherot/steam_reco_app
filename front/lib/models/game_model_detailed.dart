/// Modèle de données représentant un jeu avec ses informations détaillées.
/// Utilisé pour afficher les détails d'un jeu (page de détail, bibliothèque utilisateur, etc.)
class GameModelDetailed {
  /// Identifiant unique du jeu (correspond à id_game dans la base de données)
  final int idGame;

  /// Nom du jeu
  final String name;

  /// Description textuelle du jeu (peut être null si non renseignée)
  final String? description;

  /// Note moyenne des reviews (entre 0.0 et 1.0, null si aucune review)
  final double? meanReview;

  /// URL de l'image de couverture du jeu.
  final String _imageUrl;

  /// Nom du studio développeur (peut être null)
  final String? studio;

  const GameModelDetailed({
    required this.idGame,
    required this.name,
    this.description,
    String? imageUrl,
    this.studio,
    this.meanReview,
  }) : _imageUrl = imageUrl ?? '';

  String get imageUrl {
    if (_imageUrl.isEmpty || _imageUrl.contains('picsum.photos')) {
      return 'https://cdn.akamai.steamstatic.com/steam/apps/$idGame/capsule_231x87.jpg';
    }
    return _imageUrl;
  }
  /// Constructeur factory permettant de créer un [GameModelDetailed] depuis un JSON.
  /// Utilisé lors du décodage des réponses de l'API.
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

  /// Convertit le modèle en Map JSON pour l'envoi à l'API.
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
