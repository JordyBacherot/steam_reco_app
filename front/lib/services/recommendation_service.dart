import 'package:front/core/network/api_client.dart';
import 'dart:developer';

/// Service providing high-level game recommendation flows.
class RecommendationService {
  final ApiClient _apiClient;

  RecommendationService(this._apiClient);

  /// Fetches game recommendations based on the user's connected Steam account.
  Future<List<dynamic>> getSteamRecommendations(String steamId) async {
    log('RecommendationService: Requesting Steam-based recommendations...');
    try {
      final response = await _apiClient.dio.get('/recommendations/$steamId');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        return _parseRecommendations(data);
      }
      return [];
    } catch (e) {
      log('RecommendationService: Steam recommendations failed: $e');
      rethrow;
    }
  }

  /// Fetches game recommendations based on games manually added to the user's library.
  Future<List<dynamic>> getManualRecommendations(int userId) async {
    log('RecommendationService: Requesting manual library recommendations...');
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

  /// Identifies and parses recommendation data from various response formats.
  List<dynamic> _parseRecommendations(dynamic data) {
    if (data == null) return [];

    // Protocol: The backend may return results under 'recommendations' or 'data' keys,
    // or as a flat list if the response structure is simplified.
    if (data is Map) {
      // Handle explicit error messages from the backend.
      if (data.containsKey('error')) {
        throw Exception(data['error']);
      }
      
      if (data.containsKey('success') && data['success'] == false) {
        throw Exception(data['message'] ?? "Unknown API error.");
      }

      if (data.containsKey('recommendations') && data['recommendations'] is List) {
        return data['recommendations'];
      }
      if (data.containsKey('data') && data['data'] is List) {
        return data['data'];
      }
    }

    if (data is List) {
      return data;
    }

    log("RecommendationService Error: Unexpected response format: $data");
    throw Exception("Unexpected recommendation format from server.");
  }
}
