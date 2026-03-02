import 'package:dio/dio.dart';
import 'package:front/models/chat_message.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  final Dio _dio = Dio();

  // API URL (To replace later with .env)
  final String _baseUrl = "http://localhost:3000";

  String? _cachedToken;

  /// TODO : MOCK TEMPORAIRE - À SUPPRIMER DÈS QUE L'AUTH FLUTTER EST EN PLACE
  /// Fait un vrai login avec l'utilisateur de seed pour récupérer un token valide
  Future<String> _getTemporaryToken() async {
    if (_cachedToken != null) return _cachedToken!;

    try {
      final response = await _dio.post(
        "$_baseUrl/auth/signin",
        data: {
          "email": "test@example.com",
          "password": "password123",
        },
      );

      _cachedToken = response.data['data']['token'] as String;
      print("Temporary token fetched successfully");
      return _cachedToken!;
    } catch (e) {
      print("Failed to fetch temporary token: $e");
      throw Exception("Auth failed");
    }
  }

  /// Envoie un message au chatbot et retourne la réponse sous forme de flux (Stream).
  /// Sur Web, Dio ne supporte pas nativement ResponseType.stream (à cause de XMLHttpRequest).
  /// On utilise donc le paquet `http` standard pour cette requête spécifique
  /// afin de lire le flux (stream) octet par octet de manière garantie.
  Stream<String> sendMessageStream({
    required String message,
    required List<ChatMessage> history,
  }) async* {
    try {
      // 1. Récupération du token
      final token = await _getTemporaryToken();

      // 2. Préparation de la requête avec le paquet `http`
      final request =
          http.Request('POST', Uri.parse("$_baseUrl/recommendations/chat"));
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "text/plain",
      });

      request.body = jsonEncode({
        "message": message,
        "history": history.map((m) => m.toJson()).toList(),
        "gamesList": [],
      });

      // 3. Envoi et lecture du flux
      final response = await request.send();

      if (response.statusCode != 200) {
        yield "\n\n**Erreur du serveur (Code ${response.statusCode}).**";
        return;
      }

      // On écoute le flux d'octets, qu'on décode en UTF-8 à la volée
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        // On remplace les balises HTML <br> par de vrais retours à la ligne Markdown
        final cleanChunk =
            chunk.replaceAll('<br>', '\n').replaceAll('<br/>', '\n');
        yield cleanChunk;
      }
    } catch (e) {
      print("Error during chat stream: $e");
      yield "\n\n**Erreur de connexion : Impossible de joindre l'IA ($e).**";
    }
  }
}
