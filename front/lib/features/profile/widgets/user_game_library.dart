import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/game_service.dart';
import 'package:front/shared/widgets/game_card.dart';
import 'package:front/shared/widgets/game_list.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:front/shared/widgets/status_views.dart';
import 'package:go_router/go_router.dart';
import 'package:front/shared/widgets/empty_state.dart';

/// Widget displaying the user's library.
/// Reacts automatically to changes in [GameService] via [Consumer].
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
  void initState() {
    super.initState();
    // Trigger the initial load after the first frame so context is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameService>().getUserGames(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Mes Jeux', topPadding: 16),
        const SizedBox(height: 12),

        Consumer<GameService>(
          builder: (context, gameService, _) {
            if (gameService.isLoadingLibrary) {
              return const LoadingView(message: "Chargement de la bibliothèque...");
            }

            if (gameService.userGames.isEmpty) {
              return EmptyState(message: "Aucun jeu dans la bibliothèque.");
            }

            return Expanded(
              child: GameList(
                games: gameService.userGames,
                emptyMessage: 'Aucun jeu dans la bibliothèque.',
                cardBuilder: (context, game) {
                  return GameCard(
                    name: game.name,
                    description: game.hours != null
                        ? "${game.hours} heures jouées"
                        : "Dans votre bibliothèque",
                    imageUrl: game.imageUrl,
                    gameId: game.idGame,
                    onTap: () => context.push('/profile/game/${game.idGame}'),
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
