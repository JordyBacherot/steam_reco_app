import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/shared/widgets/section_title.dart';

class ChatPreviewCard extends StatelessWidget {
  final Map<String, dynamic> lastChat;
  final VoidCallback onMorePressed;

  const ChatPreviewCard({
    super.key,
    required this.lastChat,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final List messages = lastChat['messages'] ?? [];
    // On prend le dernier message de l'assistant pour la preview
    final lastMessage =
        messages.isNotEmpty ? messages.last['content'] : "Aucun message";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Dernière discussion IA :'),
        Card(
          elevation: 3,
          color: const Color(0xFF1B2838), // Ton sombre Steam-like
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lastMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white70, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onMorePressed,
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text("Voir la conversation"),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
