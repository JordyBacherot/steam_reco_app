// File: front/features/chatbot/widgets/chat_input.dart

import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';

/// A widget containing the text field and send button for the chatbot.
class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onSubmitted;

  const ChatInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.darkerBlue, // Couleurs Steam pour la barre de saisie
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: isLoading ? null : onSubmitted,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Posez une question sur vos jeux...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.darkBlue,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue, // Bouton d'envoi bleu Steam
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppTheme.darkBlue),
                onPressed:
                    isLoading ? null : () => onSubmitted(controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
