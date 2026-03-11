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

      // On écoute le flux d'octets, qu'on décode en UTF-8 à la volée.
      // Au lieu d'utiliser LineSplitter (qui casse si le JSON contient "\n"),
      // on parse le stream en accumulant un buffer et en cherchant la séparation "\n" typique du NDJSON.
      String buffer = "";
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;

        // Tant qu'on a un retour à la ligne dans le buffer
        int newlineIndex;
        while ((newlineIndex = buffer.indexOf('\n')) != -1) {
          // On extrait la ligne complète
          String line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1); // Reste

          if (line.isEmpty) continue;

          try {
            final data = jsonDecode(line);

            if (data['session_id'] != null) {
              currentSessionId = data['session_id'];
            }

            if (data['message'] != null) {
              final msgChunk = data['message'] as String;
              if (msgChunk.isNotEmpty) {
                // Remplacement des sauts de ligne si besoin
                yield msgChunk
                    .replaceAll('<br>', '\n')
                    .replaceAll('<br/>', '\n');
              }
            }
          } catch (e) {
            // S'il y a une erreur de parsing (ex: JSON incomplet),
            // on remet la ligne dans le buffer (en réajoutant le \n) pour attendre la suite du flux.
            buffer = line + '\n' + buffer;
            break; // On sort du while pour attendre le prochain 'chunk'
          }
        }
      }
    } catch (e) {
      print("Error during chat stream: $e");
      yield "\n\n**Erreur de connexion : Impossible de joindre l'IA ($e).**";
    }
  }
}
