import 'package:front/models/game_model.dart';

/// Represents one full recommendation session: a list of games,
/// a type (IA or Chatbot), and the date/time it was generated.
class RecommendationModel {
  final List<GameModel> games;
  final String type; // 'IA' or 'Chatbot'
  final DateTime createdAt;

  const RecommendationModel({
    required this.games,
    required this.type,
    required this.createdAt,
  });

  String get label {
    if (type == 'Chatbot') return 'Session Chatbot';
    return '${games.length} jeu${games.length > 1 ? 'x' : ''} recommandé${games.length > 1 ? 's' : ''}';
  }
}
