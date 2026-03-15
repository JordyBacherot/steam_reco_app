// File: front/features/chatbot/widgets/chat_bubble.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:front/models/chat_message.dart';
import 'package:front/core/theme/app_theme.dart';

/// A widget displaying a single chat bubble for either the user or the assistant.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isAssistant)
            const CircleAvatar(
              backgroundColor: AppTheme.darkerBlue,
              child:
                  Icon(Icons.smart_toy, color: AppTheme.primaryBlue, size: 20),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryBlue.withOpacity(0.2)
                    : AppTheme.darkerBlue,
                borderRadius: BorderRadius.circular(16),
                border: message.isUser
                    ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.5))
                    : null,
              ),
              child: MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.white),
                  h1: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  h2: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  h3: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  listBullet: const TextStyle(color: Colors.white),
                  code: TextStyle(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(Icons.person, color: AppTheme.darkBlue, size: 20),
            ),
        ],
      ),
    );
  }
}
