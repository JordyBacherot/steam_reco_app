import 'package:front/core/network/api_client.dart';
import 'dart:developer';

class RecommendationService {
  final ApiClient _apiClient;

  RecommendationService(this._apiClient);

  /// Fetch recommendations from Steam based on steamId
  Future<List<dynamic>> getSteamRecommendations(String steamId) async {
    try {
      final response = await _apiClient.dio.get('/recommendations/$steamId');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        return _parseRecommendations(data);
      }
      return [];
    } catch (e) {
      log("Error fetching steam recommendations: $e");
      rethrow;
    }
  }

  /// Fetch recommendations based on manual games for a specific user
  Future<List<dynamic>> getManualRecommendations(int userId) async {
    try {
      // 1. Fetch user games
      final gamesResponse = await _apiClient.dio.get('/users/$userId/games');
      if (gamesResponse.statusCode != 200) {
         throw Exception("Impossible de récupérer la liste des jeux.");
      }
      
      final List<dynamic> userGamesData = gamesResponse.data['data'] ?? [];
      if (userGamesData.length < 3) {
          throw Exception("Pas assez de jeux manuels pour générer une recommandation (minimum 3).");
      }

      // 2. Map payload
      final List<Map<String, dynamic>> payloadGames = userGamesData.map((item) {
         final gameData = item['game'] ?? {};
         final int gameId = item['id_game'] ?? gameData['id_game'] ?? 0;
         final int hours = item['nb_hours'] ?? 0;
         return {
           "game_id": gameId,
           "hours": hours
         };
      }).toList();

      // 3. POST request
      final manualResponse = await _apiClient.dio.post(
         '/recommendations/manual', 
         data: {
           "games": payloadGames,
           "limit": 10
         }
      );
      
      if (manualResponse.statusCode == 200 && manualResponse.data != null) {
         final data = manualResponse.data;
         return _parseRecommendations(data);
      }
      return [];
    } catch (e) {
      log("Error fetching manual recommendations: $e");
      rethrow;
    }
  }

  List<dynamic> _parseRecommendations(dynamic data) {
    if (data == null) return [];

    // 1. Handle Map response
    if (data is Map) {
      // Check for error field from backend
      if (data.containsKey('error')) {
        throw Exception(data['error']);
      }
      
      // Check for success flag (if backend uses it)
      if (data.containsKey('success') && data['success'] == false) {
        throw Exception(data['message'] ?? "Erreur inconnue de l'API");
      }

      // Try different common keys for list of items
      if (data.containsKey('recommendations') && data['recommendations'] is List) {
        return data['recommendations'];
      }
      if (data.containsKey('data') && data['data'] is List) {
        return data['data'];
      }
    }

    // 2. Handle direct List response
    if (data is List) {
      return data;
    }

    // 3. Fallback/Error
    log("[RecommendationService] Format de réponse inattendu: $data");
    throw Exception("Format de recommandation inattendu depuis le serveur.");
  }
}
