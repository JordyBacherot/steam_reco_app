import 'package:flutter/material.dart';
import 'package:front/models/recommendation_model.dart';
import 'package:intl/intl.dart';
import 'package:front/core/theme/app_theme.dart';

/// Displays a single recommendation session as a horizontal card.
class RecommendationCard extends StatelessWidget {
  final RecommendationModel recommendation;
  final VoidCallback? onTap;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIA = recommendation.type == 'IA';
    final formattedDate = DateFormat('dd/MM/yyyy – HH:mm').format(recommendation.createdAt);
    final game = recommendation.games.isNotEmpty ? recommendation.games.first : null;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [

              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isIA
                      ? Colors.deepPurpleAccent.withOpacity(0.7)
                      : Colors.teal.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  recommendation.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Game thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: game?.imageUrl != null
                    ? Image.network(
                        game!.imageUrl,
                        width: 90,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),

              // Date — takes remaining space, truncates if needed
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 90,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.videogame_asset, color: Colors.white24, size: 20),
      );
}