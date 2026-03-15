import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/game_service.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/shared/widgets/game_card.dart';
import 'package:front/shared/widgets/game_list.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:front/shared/widgets/status_views.dart';
import 'package:go_router/go_router.dart';
import 'package:front/shared/widgets/empty_state.dart';

/// Widget displaying the user's library.
/// This version uses FutureBuilder for consistency with AddGamesPage,
/// ensuring the list is loaded before being displayed.
class UserGameLibrary extends StatefulWidget {
  final int userId;

  const UserGameLibrary({
    super.key,
    required this.userId,
  });

  @override
  State<UserGameLibrary> createState() => _UserGameLibraryState();
}

class _UserGameLibraryState extends State<UserGameLibrary> {
  @override
  Widget build(BuildContext context) {
    final gameService = context.read<GameService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Mes Jeux', topPadding: 16),
        const SizedBox(height: 12),

        // FutureBuilder fetches the games once and rebuilds automatically
        FutureBuilder<List<GameModelDetailed>>(
          future: gameService.getUserGames(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView(
                  message: "Chargement de la bibliothèque...");
            }

            if (snapshot.hasError) {
              return ErrorView(
                message: "Erreur lors du chargement de la bibliothèque",
                onRetry: () => setState(() {}),
              );
            }

            final games = snapshot.data ?? [];

            if (games.isEmpty) {
              // REMOVE const here
              return EmptyState(
                  message: "Aucun jeu dans la bibliothèque.");
            }

            return Expanded(
              child: GameList(
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
              ),
            );
          },
        ),
      ],
    );
  }
}