import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/models/near_game_model.dart';
import 'package:front/core/theme/app_theme.dart';

class SimilarGamesList extends StatelessWidget {
  final List<NearGameModel> similarGames;

  const SimilarGamesList({super.key, required this.similarGames});

  void _navigateToSimilarGame(BuildContext context, int targetAppId) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    if (currentPath.startsWith('/profile')) {
      context.push('/profile/game/$targetAppId');
    } else if (currentPath.startsWith('/reco')) {
      context.push('/reco/game/$targetAppId');
    } else {
      context.push('/game/$targetAppId');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (similarGames.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "Jeux similaires :",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...similarGames.map((game) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => _navigateToSimilarGame(context, game.appid),
                child: Text(
                  "→ ${game.name} (${(game.score * 100).toStringAsFixed(0)}%)",
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.primaryBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primaryBlue,
                  ),
                ),
              ),
            )),
        const SizedBox(height: 32),
      ],
    );
  }
}
