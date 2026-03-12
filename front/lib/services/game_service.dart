import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/core/network/secure_storage.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/models/near_game_model.dart';

/// Service responsable de toutes les requêtes HTTP liées aux jeux.
/// Communique avec l'API Hono pour récupérer les données de jeux,
/// les jeux similaires et la bibliothèque d'un utilisateur.
class GameService {
  /// URL de base de l'API, chargée depuis le fichier .env
  final String _baseUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";

  /// Service de stockage sécurisé pour accéder au token JWT de l'utilisateur connecté
  final SecureStorage _secureStorage = SecureStorage();

  /// Récupère les détails complets d'un jeu à partir de son identifiant.
  /// Retourne null en cas d'erreur ou si le jeu n'existe pas.
  Future<GameModelDetailed?> getGameById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/games/$id"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Vérifie que l'API a renvoyé un succès et des données valides
        if (data['success'] == true && data['data'] != null) {
          return GameModelDetailed.fromJson(data['data']);
        } else {
          print("[GameService] Error: invalid game data structure: $data");
          return null;
        }
      } else {
        print("[GameService] Error fetching game $id: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("[GameService] Exception fetching game $id: $e");
      return null;
    }
  }

  /// Récupère la liste des jeux similaires à un jeu donné, via l'algorithme de recommandation par voisinage (nearest games).
  /// Le paramètre [limit] permet de limiter le nombre de résultats (défaut: 5).
  /// Nécessite un token JWT si l'utilisateur est connecté.
  Future<List<NearGameModel>> getNearestGames(int id, {int limit = 5}) async {
    try {
      // Lecture du token JWT stocké localement
      final token = await _secureStorage.readToken();
      final headers = {
        "Accept": "application/json",
      };
      
      // Ajout du token dans les headers si l'utilisateur est connecté
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.get(
        Uri.parse("$_baseUrl/recommendations/nearest_games/$id?limit=$limit"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // L'API retourne found:true et nearest_games si des résultats existent
        if (data['found'] == true && data['nearest_games'] != null) {
          final List<dynamic> jsonList = data['nearest_games'];
          return jsonList.map((j) => NearGameModel.fromJson(j)).toList();
        }
        return [];
      } else {
        print("[GameService] Error fetching recommendations for game $id: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("[GameService] Exception fetching nearest games $id: $e");
      return [];
    }
  }

  /// Récupère la liste des jeux appartenant à la bibliothèque d'un utilisateur.
  /// L'API retourne des entités GameUser (relation user-jeu), on en extrait la partie "game".
  /// Nécessite un token JWT valide.
  Future<List<GameModelDetailed>> getUserGames(int userId) async {
    try {
      // Lecture du token JWT stocké localement
      final token = await _secureStorage.readToken();
      final headers = {
        "Accept": "application/json",
      };
      
      // Ajout du token dans les headers pour l'authentification
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.get(
        Uri.parse("$_baseUrl/users/$userId/games"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("[GameService] getUserGames response: $data");
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> jsonList = data['data'];
          // La réponse est une liste de GameUser : { id_user, id_game, nb_hours, game: {...} }
          // On extrait uniquement l'objet "game" imbriqué pour le mapper en GameModelDetailed
          return jsonList
              .map((item) => item['game'])
              .where((game) => game != null)
              .map((game) => GameModelDetailed.fromJson(game))
              .toList();
        }
        return [];
      } else {
        print("[GameService] Error fetching games for user $userId: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("[GameService] Exception fetching user games $userId: $e");
      return [];
    }
  }
}
