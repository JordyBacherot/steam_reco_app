import 'package:front/models/chat_message.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:front/core/network/api_client.dart';
import 'dart:developer';

/// Service managing interactions with the AI chatbot through streaming responses.
class ChatbotService {
  final ApiClient _apiClient;

  ChatbotService(this._apiClient);
  
  /// Persistent session identifier for maintaining conversation context.
  String? currentSessionId;

  /// Resets the conversation by clearing the current session ID.
  void resetSession() {
    currentSessionId = null;
    log("ChatbotService: Session reset.");
  }

  /// Fetches the last chatbot conversation from the server.
  ///
  /// Returns a map with `session_id` and `messages` (list of response maps),
  /// or `null` if no conversation history exists.
  Future<Map<String, dynamic>?> fetchLastConversation() async {
    try {
      final response = await _apiClient.dio.get(
        "/recommendations/history/chat",
        queryParameters: {"limit": 1},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List history = data['history_chat'] ?? [];
        if (history.isNotEmpty) {
          return history.first as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      log("Error fetching last conversation: $e");
      return null;
    }
  }

  /// Sends a message and returns an asynchronous stream of response chunks.
  ///
  /// [message] The user's prompt.
  /// [history] The preceding messages in the conversation for context.
  Stream<String> sendMessageStream({
    required String message,
    required List<ChatMessage> history,
  }) async* {
    try {
      final Map<String, dynamic> bodyData = {
        "message": message,
        "history": history.map((m) => m.toJson()).toList(),
      };

      if (currentSessionId != null) {
        bodyData["session_id"] = currentSessionId;
      }

      final response = await _apiClient.dio.post(
        "/recommendations/chat",
        data: bodyData,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            "Accept": "text/plain",
          },
        ),
      );

      if (response.statusCode != 200) {
        yield "\n\n**Erreur du serveur (Code ${response.statusCode}).**";
        return;
      }

      // 3. Extraction du session_id des Headers de la réponse (Garde au cas où)
      if (response.headers.value('x-session-id') != null) {
        currentSessionId = response.headers.value('x-session-id');
      }

      final ResponseBody stream = response.data;
      String buffer = "";

      await for (final chunk in stream.stream.cast<List<int>>().transform(utf8.decoder)) {
        buffer += chunk;

        int newlineIndex;
        while ((newlineIndex = buffer.indexOf('\n')) != -1) {
          String line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.isEmpty) continue;

          try {
            final data = jsonDecode(line);

            if (data['session_id'] != null) {
              currentSessionId = data['session_id'];
            }

            if (data['message'] != null) {
              final msgChunk = data['message'] as String;
              if (msgChunk.isNotEmpty) {
                yield msgChunk
                    .replaceAll('<br>', '\n')
                    .replaceAll('<br/>', '\n');
              }
            }
          } catch (e) {
            // Buffer management if JSON is incomplete
            buffer = line + '\n' + buffer;
            break;
          }
        }
      }
    } catch (e) {
      log("Error during chat stream: $e");
      yield "\n\n**Erreur de connexion : Impossible de joindre l'IA ($e).**";
    }
  }
}
