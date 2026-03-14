import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/game_service.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/shared/widgets/game_card.dart';
import 'package:front/shared/widgets/game_list.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:front/shared/widgets/status_views.dart';
import 'package:go_router/go_router.dart';

/// Shows the list of games owned by the user.
class UserGameLibrary extends StatelessWidget {
  final int userId;
  const UserGameLibrary({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Mes Jeux', topPadding: 16),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<List<GameModelDetailed>>(
            future: Provider.of<GameService>(context, listen: false)
                .getUserGames(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView(message: "Chargement de la bibliothèque...");
              } else if (snapshot.hasError) {
                return ErrorView(
                  message: "Erreur de chargement de la bibliothèque",
                  onRetry: () => (context as Element).markNeedsBuild(),
                );
              }

              final games = snapshot.data ?? [];
              return GameList(
                games: games,
                emptyMessage: 'Aucun jeu dans la bibliothèque.',
                cardBuilder: (context, game) {
                  final g = game as GameModelDetailed;
                  return GameCard(
                    name: g.name,
                    description: g.hours != null
                        ? "${g.hours} heures jouées"
                        : "Dans votre bibliothèque",
                    imageUrl: g.imageUrl,
                    gameId: g.idGame,
                    onTap: () => context.push('/profile/game/${g.idGame}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}