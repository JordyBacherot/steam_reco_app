import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';

/// A card widget representing a specific game.
///
/// Displays the game's image, title, and a short description.
/// Designed for use within scrollable lists or grids.
class GameCard extends StatelessWidget {
  /// The official title of the game.
  final String name;
  
  /// A brief summary or description of the game.
  final String description;
  
  /// The URL for the game's capsule image.
  final String? imageUrl;
  
  /// The unique identifier for the game.
  final int? gameId;
  
  /// Callback function triggered when the card is tapped.
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.name,
    required this.description,
    this.imageUrl,
    this.gameId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardGrey,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          width: 120,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(width: 16),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.greyText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 120,
      height: 65,
      color: Colors.grey[800],
      child: const Icon(Icons.videogame_asset, color: Colors.grey),
    );
  }
}
