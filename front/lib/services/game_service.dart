import 'package:front/core/network/api_client.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/models/near_game_model.dart';
import 'dart:developer';

/// Service responsable de toutes les requêtes HTTP liées aux jeux.
/// Communique avec l'API Hono pour récupérer les données de jeux,
/// les jeux similaires et la bibliothèque d'un utilisateur.
class GameService {
  final ApiClient _apiClient;

  GameService(this._apiClient);

  /// Recherche des jeux par nom via le nouvel endpoint /games/search.
  /// Le paramètre [limit] permet de limiter le nombre de résultats (défaut: 15).
  Future<List<GameModelDetailed>> searchGames(String query, {int limit = 15}) async {
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

  /// Récupère les détails complets d'un jeu à partir de son identifiant.
  /// Retourne null en cas d'erreur ou si le jeu n'existe pas.
  Future<GameModelDetailed?> getGameById(int id) async {
    try {
      final response = await _apiClient.dio.get("/games/$id");

      if (response.statusCode == 200) {
        final data = response.data;
        // Vérifie que l'API a renvoyé un succès et des données valides
        if (data['success'] == true && data['data'] != null) {
          return GameModelDetailed.fromJson(data['data']);
        } else {
          log("[GameService] Error: invalid game data structure: $data");
          return null;
        }
      } else {
        log("[GameService] Error fetching game $id: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("[GameService] Exception fetching game $id: $e");
      return null;
    }
  }

  /// Récupère la liste des jeux similaires à un jeu donné, via l'algorithme de recommandation par voisinage (nearest games).
  /// Le paramètre [limit] permet de limiter le nombre de résultats (défaut: 5).
  Future<List<NearGameModel>> getNearestGames(int id, {int limit = 5}) async {
    try {
      final response = await _apiClient.dio.get(
        "/recommendations/nearest_games/$id",
        queryParameters: {"limit": limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // L'API retourne found:true et nearest_games si des résultats existent
        if (data['found'] == true && data['nearest_games'] != null) {
          final List<dynamic> jsonList = data['nearest_games'];
          return jsonList.map((j) => NearGameModel.fromJson(j)).toList();
        }
        return [];
      } else {
        log("[GameService] Error fetching recommendations for game $id: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      log("[GameService] Exception fetching nearest games $id: $e");
      return [];
    }
  }

  /// Récupère la bibliothèque de jeux d'un utilisateur.
  Future<List<GameModelDetailed>> getUserGames(int userId) async {
    try {
      final response = await _apiClient.dio.get("/users/$userId/games");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> jsonList = data['data'];
          return jsonList
              .map((item) => item['game'])
              .where((game) => game != null)
              .map((game) => GameModelDetailed.fromJson(game))
              .toList();
        }
        return [];
      } else {
        log("[GameService] Error fetching games for user $userId: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      log("[GameService] Exception fetching user games $userId: $e");
      return [];
    }
  }

  /// Ajoute un jeu à la bibliothèque de l'utilisateur.
  Future<bool> addUserGame({
    required int userId,
    required int gameId,
    required int hours,
    required String gameTitle,
    required String gameImageUrl,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/users/$userId/games',
        data: {
          'id_game': gameId,
          'nb_hours': hours,
          'game_title': gameTitle,
          'game_image_url': gameImageUrl,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('[GameService] Error adding user game: $e');
      return false;
    }
  }

  /// Retire un jeu de la bibliothèque de l'utilisateur.
  Future<bool> deleteUserGame(int userId, String gameId) async {
    try {
      final response = await _apiClient.dio.delete('/users/$userId/games/$gameId');
      return response.statusCode == 200;
    } catch (e) {
      log('[GameService] Error deleting user game: $e');
      return false;
    }
  }
}
