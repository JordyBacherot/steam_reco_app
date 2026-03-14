class ReviewModel {
  //Attributs de la table Review
  final int idReview;
  final int idGame;
  final int idUser;
  final String text;

  final String username;

  ReviewModel({
    required this.idReview,
    required this.idGame,
    required this.idUser,
    required this.text,
    required this.username,
  });

  /// Création d'un ReviewModel à partir d'un JSON.
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      idReview: json['id_review'] as int,
      idGame: json['id_game'] as int,
      idUser: json['id_user'] as int,
      text: json['text'] as String? ?? '',
      username: json['user']?['username'] as String? ?? 'Utilisateur inconnu',
    );
  }

  /// Conversion d'un ReviewModel en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id_review': idReview,
      'id_game': idGame,
      'id_user': idUser,
      'text': text,
    };
  }
}
