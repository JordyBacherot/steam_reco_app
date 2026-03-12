import 'package:flutter/material.dart';
import 'package:front/models/recommendation_model.dart';
import 'package:intl/intl.dart';

/// Displays a single recommendation session as a card.
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF2A475E),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header: type badge + date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Label: e.g. "5 jeux recommandés" or "Session Chatbot"
              Text(
                recommendation.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Thumbnail strip (IA sessions only)
              if (recommendation.games.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendation.games.length > 5 ? 5 : recommendation.games.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, i) {
                      final game = recommendation.games[i];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          game.imageUrl,
                          width: 90,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90,
                            height: 46,
                            color: Colors.grey[800],
                            child: const Icon(Icons.videogame_asset, color: Colors.white54, size: 20),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
