import 'package:front/core/network/api_client.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/models/near_game_model.dart';
import 'package:front/models/review_model.dart';
import 'dart:developer';
import 'package:flutter/material.dart';


/// Service responsible for all game-related HTTP requests.
/// 
/// Communicates with the backend API to retrieve game data, 
/// similar games, and manage user libraries.
class GameService extends ChangeNotifier {
  final ApiClient _apiClient;
  int _addedGamesCount = 0;
  bool _isLoadingLibrary = false;
  List<GameModelDetailed> _userGames = [];

  bool get isLoadingLibrary => _isLoadingLibrary;
  List<GameModelDetailed> get userGames => _userGames;

  GameService(this._apiClient);

  int get addedGamesCount => _addedGamesCount;

  /// Searches the game database for matches to [query].
  ///
  /// Returns a list of [GameModelDetailed] instances.
  Future<List<GameModelDetailed>> searchGames(String query, {int limit = 15}) async {
    log('GameService: Searching for "$query" with limit $limit...');
    try {
      final response = await _apiClient.dio.get(
        "/games/search",
        queryParameters: {"q": query, "limit": limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> jsonList = data['data'];
          return jsonList.map((j) => GameModelDetailed.fromJson(j)).toList();
        }
        return [];
      } else {
        log("[GameService] Error searching games: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      log("[GameService] Exception searching games: $e");
      return [];
    }
  }

  /// Retrieves comprehensive metadata for a specific game by its [id].
  Future<GameModelDetailed?> getGameById(int id) async {
    log('GameService: Fetching details for game $id...');
    try {
      final response = await _apiClient.dio.get("/games/$id");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return GameModelDetailed.fromJson(data['data']);
        }
      }
    } catch (e) {
      log("GameService: Failed to fetch game $id: $e");
    }
    return null;
  }

  /// Fetches a list of games similar to the one identified by [query].
  ///
  /// Similarity is determined by backend recommendation algorithms.
  Future<List<NearGameModel>> getNearestGames(String query) async {
    log('GameService: Fetching nearest games for "$query"...');
    try {
      final response = await _apiClient.dio.get('/recommendations/nearest_games/$query');

      if (response.statusCode == 200) {
        final List data = response.data['nearest_games'] ?? [];
        return data.map((json) => NearGameModel.fromJson(json)).toList();
      }
    } catch (e) {
      log('GameService: Failed to fetch nearest games for "$query": $e');
    }
    return [];
  }

  /// Retrieves the list of games currently in a specific user's library.
  Future<List<GameModelDetailed>> getUserGames(int userId) async {
    try {
      final response = await _apiClient.dio.get('/users/$userId/games');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        _addedGamesCount = data.length;
        notifyListeners();
        return data.map((j) => GameModelDetailed.fromJson(j)).toList();
      }
    } catch (e) {
      log('Failed to fetch user library: $e');
    }
    return [];
  }

  /// Adds a game to the user's library with the specified [hoursPlayed].
  Future<bool> addUserGame({
    required int userId,
    required int gameId,
    required int hours,
    required String gameTitle,
    required String gameImageUrl,
  }) async {
    log('GameService: Adding game $gameId ("$gameTitle") for user $userId with $hours hours...');
    try {
      final response = await _apiClient.dio.post('/users/$userId/games', data: {
        'id_user': userId,
        'id_game': gameId,
        'nb_hours': hours,
        'game_title': gameTitle,
        'game_image_url': gameImageUrl,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('GameService: Failed to add game $gameId for user $userId: $e');
    }
    return false;
  }

  /// Removes a game from the user's library.
  Future<bool> deleteUserGame(int userId, String gameId) async {
    log('GameService: Removing game $gameId from user $userId library...');
    try {
      // Assuming backend supports DELETE /user-games/:userId/:gameId or similar
      // Or a generic DELETE with body if it matches the current implementation
      final response = await _apiClient.dio.delete('/users/$userId/games/$gameId');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      log('GameService: Failed to delete game $gameId for user $userId: $e');
    }
    return false;
  }

  /// Fetches trending games for a specific geographical [continent].
  Future<List<GameModelDetailed>> getTrendingGamesByContinent(String continent) async {
    log('GameService: Fetching trending games for $continent...');
    try {
      final response = await _apiClient.dio.get('/games/trending/$continent');

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => GameModelDetailed.fromJson(json)).toList();
      }
    } catch (e) {
      log('GameService: Failed to fetch trending for $continent: $e');
    }
    return [];
  }

  /// Fetches all reviews for a specific game.
  Future<List<ReviewModel>> getReviewsForGame(int gameId) async {
    log('GameService: Fetching reviews for game $gameId...');
    try {
      final response = await _apiClient.dio.get('/reviews/game/$gameId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((j) => ReviewModel.fromJson(j)).toList();
      }
    } catch (e) {
      log('GameService: Failed to fetch reviews for game $gameId: $e');
    }
    return [];
  }

  /// Posts a new review for a game.
  Future<bool> postReview({
    required int gameId,
    required int userId,
    required String text,
  }) async {
    log('GameService: Posting review for game $gameId by user $userId...');
    try {
      final response = await _apiClient.dio.post('/reviews', data: {
        'id_game': gameId,
        'id_user': userId,
        'text': text,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('GameService: Failed to post review for game $gameId: $e');
    }
    return false;
  }
}
