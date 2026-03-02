import 'package:flutter/material.dart';
import 'package:front/features/main/models/game_model.dart';

class AddedGameCard extends StatelessWidget {
  final GameModel game;
  final int rating;
  final VoidCallback onDelete;

  const AddedGameCard({
    super.key,
    required this.game,
    required this.rating,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: const Color(0xFF171a21), // Slightly darker background for list items
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Rating
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF66c0f4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$rating/5',
                style: const TextStyle(
                  color: Color(0xFF66c0f4),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Game Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                game.imageUrl,
                width: 80,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 36,
                  color: Colors.grey[800],
                  child: const Icon(Icons.videogame_asset, color: Colors.white54, size: 20),
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
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
