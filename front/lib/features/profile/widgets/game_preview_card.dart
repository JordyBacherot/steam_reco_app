import 'package:flutter/material.dart';
import 'package:front/features/main/models/game_model.dart';

class GamePreviewCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onAddPressed;

  const GamePreviewCard({
    super.key,
    required this.game,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aperçu:',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          color: const Color(0xFF2A475E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Game Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    game.imageUrl,
                    width: 100,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 46,
                      color: Colors.grey[800],
                      child: const Icon(Icons.videogame_asset, color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Game Title
                Expanded(
                  child: Text(
                    game.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Add Button
                IconButton(
                  onPressed: onAddPressed,
                  icon: const Icon(Icons.add_circle, color: Color(0xFF66c0f4), size: 32),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
