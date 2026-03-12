/// Modèle représentant un jeu similaire (proche) retourné par l'algorithme de recommandation.
/// Contient les informations minimales nécessaires pour afficher une suggestion de jeu similaire.
class NearGameModel {
  /// Identifiant Steam du jeu (appid Steam)
  final int appid;

  /// Nom du jeu
  final String name;

  /// Score de similarité
  final double score;

  const NearGameModel({
    required this.appid,
    required this.name,
    required this.score,
  });

  /// Constructeur factory permettant de créer un [NearGameModel] depuis un JSON.
  factory NearGameModel.fromJson(Map<String, dynamic> json) {
    return NearGameModel(
      appid: json['appid'] as int,
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }

  /// Convertit le modèle en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'appid': appid,
      'name': name,
      'score': score,
    };
  }
}
