import 'package:front/models/chat_message.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/core/network/secure_storage.dart';

class ChatbotService {
  // L'URL de l'API lue depuis le fichier .env
  final String _baseUrl = dotenv.env['API_URL'] ?? "http://localhost:3000";

  // Identifiant de session pour l'historique de discussion
  String? currentSessionId;
  final SecureStorage _secureStorage = SecureStorage();

  /// Réinitialise la session pour démarrer une nouvelle conversation
  void resetSession() {
    currentSessionId = null;
    print("[ChatbotService] Session réinitialisée.");
  }



  /// Envoie un message au chatbot et retourne la réponse sous forme de flux (Stream).
  /// Sur Web, XmlHttpRequest ne gère pas bien les streams natifs en écriture,
  /// on utilise un appel HTTP manuel natif pour lire en flux continu octet par octet.
  Stream<String> sendMessageStream({
    required String message,
    required List<ChatMessage> history,
  }) async* {
    try {
      final token = await _secureStorage.readToken();
      if (token == null) {
        yield "\n\n**Erreur : Utilisateur non authentifié.**";
        return;
      }

      // 1. Préparation de la requête avec le paquet `http`
      final request =
          http.Request('POST', Uri.parse("$_baseUrl/recommendations/chat"));
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "text/plain",
      });

      final Map<String, dynamic> bodyData = {
        "message": message,
        "history": history.map((m) => m.toJson()).toList(),
        "gamesList": [],
      };

      // Si on a déjà commencé une session, on passe l'ID
      if (currentSessionId != null) {
        bodyData["session_id"] = currentSessionId;
      }

      request.body = jsonEncode(bodyData);

      // 2. Envoi et lecture du flux
      final response = await request.send();

      if (response.statusCode != 200) {
        yield "\n\n**Erreur du serveur (Code ${response.statusCode}).**";
        return;
      }

      // 3. Extraction du session_id des Headers de la réponse (Garde au cas où)
      if (response.headers.containsKey('x-session-id')) {
        currentSessionId = response.headers['x-session-id'];
      }

      // On écoute le flux d'octets, qu'on décode en UTF-8, puis on le coupe par ligne
      await for (final line in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        
        if (line.trim().isEmpty) continue;

        try {
          final data = jsonDecode(line);
          
          if (data['session_id'] != null) {
            currentSessionId = data['session_id'];
          }
          
          if (data['message'] != null) {
            final msgChunk = data['message'] as String;
            if (msgChunk.isNotEmpty) {
              yield msgChunk.replaceAll('<br>', '\n').replaceAll('<br/>', '\n');
            }
          }
        } catch (e) {
          print("Erreur de parsing JSON sur le chunk : $line");
        }
      }
    } catch (e) {
      print("Error during chat stream: $e");
      yield "\n\n**Erreur de connexion : Impossible de joindre l'IA ($e).**";
    }
  }
}
