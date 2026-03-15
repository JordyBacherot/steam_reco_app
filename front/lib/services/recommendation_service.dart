import 'package:flutter/material.dart';
import 'package:front/core/network/api_client.dart';
import 'dart:developer';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Represents a single AI recommendation entry from the history endpoint.
class AiRecommendationEntry {
  final int userId;
  final int gameId;
  final double score;
  final DateTime createdAt;
  final String gameName;
  final String gameDescription;
  final String gameImageUrl;
  final double meanReview;
  final String studio;

  AiRecommendationEntry({
    required this.userId,
    required this.gameId,
    required this.score,
    required this.createdAt,
    required this.gameName,
    required this.gameDescription,
    required this.gameImageUrl,
    required this.meanReview,
    required this.studio,
  });

  factory AiRecommendationEntry.fromJson(Map<String, dynamic> json) {
    final game = json['game'] as Map<String, dynamic>? ?? {};
    return AiRecommendationEntry(
      userId: json['id_user'] as int,
      gameId: json['id_game'] as int,
      score: (json['score'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      gameName: game['name'] as String? ?? '',
      gameDescription: game['description'] as String? ?? '',
      gameImageUrl: game['image_url'] as String? ?? '',
      meanReview: double.tryParse(game['mean_review']?.toString() ?? '') ?? 0.0,
      studio: game['studio'] as String? ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Service providing high-level game recommendation flows.
///
/// Extends [ChangeNotifier] so that UI widgets can reactively rebuild
/// when [aiHistory] or [isLoadingHistory] changes.
class RecommendationService extends ChangeNotifier {
  final ApiClient _apiClient;

  RecommendationService(this._apiClient);

  // --- AI history state (reactive) -----------------------------------------

  List<AiRecommendationEntry> _aiHistory = [];
  bool _isLoadingHistory = false;

  List<AiRecommendationEntry> get aiHistory => _aiHistory;
  bool get isLoadingHistory => _isLoadingHistory;

  // ---------------------------------------------------------------------------
  // AI History — updates state and notifies listeners
  // ---------------------------------------------------------------------------

  /// Fetches the AI recommendation history and updates [aiHistory].
  ///
  /// [limit] controls how many entries are returned (default 10).
  /// Always resets [isLoadingHistory] whether the call succeeds or fails.
  Future<void> fetchAiHistory({int limit = 10}) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      log('RecommendationService: Fetching AI history (limit: $limit)...');
      final response = await _apiClient.dio.get(
        '/recommendations/history/ai',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw =
            response.data['history_ai'] as List<dynamic>? ?? [];
        _aiHistory = raw
            .map((e) => AiRecommendationEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        log('RecommendationService: Loaded ${_aiHistory.length} AI history entries.');
      }
    } catch (e) {
      log('RecommendationService: Failed to fetch AI history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Recommendations — plain async methods, no state needed
  // ---------------------------------------------------------------------------

  /// Fetches game recommendations based on the user's connected Steam account.
  Future<List<dynamic>> getSteamRecommendations(String steamId) async {
    log('RecommendationService: Requesting Steam-based recommendations...');
    try {
      final response = await _apiClient.dio.get('/recommendations/$steamId');

      if (response.statusCode == 200 && response.data != null) {
        return _parseRecommendations(response.data);
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
      final gamesResponse = await _apiClient.dio.get('/users/$userId/games');
      if (gamesResponse.statusCode != 200) {
        throw Exception("Impossible de récupérer la liste des jeux.");
      }

      final List<dynamic> userGamesData =
          gamesResponse.data['data'] as List<dynamic>? ?? [];
      if (userGamesData.length < 3) {
        throw Exception(
            "Pas assez de jeux manuels pour générer une recommandation (minimum 3).");
      }

      final List<Map<String, dynamic>> payloadGames =
          userGamesData.map((item) {
        final gameData = item['game'] as Map<String, dynamic>? ?? {};
        final int gameId = item['id_game'] ?? gameData['id_game'] ?? 0;
        final int hours = item['nb_hours'] ?? 0;
        return {"game_id": gameId, "hours": hours};
      }).toList();

      final manualResponse = await _apiClient.dio.post(
        '/recommendations/manual',
        data: {"games": payloadGames, "limit": 10},
      );

      if (manualResponse.statusCode == 200 && manualResponse.data != null) {
        return _parseRecommendations(manualResponse.data);
      }
      return [];
    } catch (e) {
      log("RecommendationService: Manual recommendations failed: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Identifies and parses recommendation data from various response formats.
  List<dynamic> _parseRecommendations(dynamic data) {
    if (data == null) return [];

    if (data is Map) {
      if (data.containsKey('error')) throw Exception(data['error']);
      if (data.containsKey('success') && data['success'] == false) {
        throw Exception(data['message'] ?? "Unknown API error.");
      }
      if (data.containsKey('recommendations') &&
          data['recommendations'] is List) {
        return data['recommendations'] as List;
      }
      if (data.containsKey('data') && data['data'] is List) {
        return data['data'] as List;
      }
    }

    if (data is List) return data;

    log("RecommendationService: Unexpected response format: $data");
    throw Exception("Unexpected recommendation format from server.");
  }
}
