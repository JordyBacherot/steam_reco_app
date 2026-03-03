import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/models/game_model.dart';

class RecommendationList extends StatelessWidget {
  final List<GameModel> games;

  const RecommendationList({
    super.key,
    required this.games,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dernière recommandations :',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true, // Needed to put a ListView inside a Column/ListView
          physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
          itemCount: games.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final game = games[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color(0xFF2A475E), // Dark blue-grey for Steam aesthetic
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  context.push('/game/${game.id}');
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Game Icon / Capsule Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          game.imageUrl,
                          width: 100,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                      // Arrow on the right
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
