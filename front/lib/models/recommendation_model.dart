import 'package:front/models/game_model.dart';

/// Represents a curated collection of game suggestions generated during a single session.
///
/// Encapsulates the results from either an AI recommendation algorithm 
/// or a chatbot conversation.
class RecommendationModel {
  /// The list of suggested games.
  final List<GameModel> games;
  
  /// The source of the recommendation (e.g., 'IA', 'Chatbot', 'Steam').
  final String type;
  
  /// The timestamp of when this recommendation was generated.
  final DateTime createdAt;

  const RecommendationModel({
    required this.games,
    required this.type,
    required this.createdAt,
  });

  /// Returns a human-readable label for the recommendation session.
  String get label {
    if (type == 'Chatbot') return 'Session Chatbot';
    return '${games.length} jeu${games.length > 1 ? 'x' : ''} recommandé${games.length > 1 ? 's' : ''}';
  }
}
