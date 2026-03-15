import 'package:flutter/material.dart';
import 'package:front/models/game_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/features/profile/widgets/game_search_row.dart';
import 'package:front/features/profile/widgets/game_preview_card.dart';
import 'package:front/features/profile/widgets/added_game_card.dart';
import 'package:front/services/game_service.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:front/shared/widgets/empty_state.dart';
import 'package:front/shared/widgets/status_views.dart';

/// Page where the user can search for games and add them to their library.
class AddGamesPage extends StatefulWidget {
  const AddGamesPage({super.key});

  @override
  State<AddGamesPage> createState() => _AddGamesPageState();
}

class _AddGamesPageState extends State<AddGamesPage> {
  GameModel? _selectedGame;
  final TextEditingController _hoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger the initial library load after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthService>().currentUser?.id;
      if (userId != null) {
        context.read<GameService>().getUserGames(userId);
      }
    });
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  /// Adds the selected game to the user's library, then refreshes the list.
  Future<void> _addGame() async {
    if (_selectedGame == null || _hoursController.text.isEmpty) return;

    final hours = int.tryParse(_hoursController.text);
    if (hours == null || hours < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un nombre d'heures valide")),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final gameService = context.read<GameService>();
    final messenger = ScaffoldMessenger.of(context);
    final userId = authService.currentUser?.id;

    if (userId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
      );
      return;
    }

    try {
      final success = await gameService.addUserGame(
        userId: userId,
        gameId: _selectedGame!.id,
        hours: hours,
        gameTitle: _selectedGame!.title,
        gameImageUrl: _selectedGame!.imageUrl,
      );

      if (success && mounted) {
        // Clear local selection state.
        setState(() {
          _selectedGame = null;
          _hoursController.clear();
        });
        // Refresh the library — Consumer will rebuild automatically.
        await gameService.getUserGames(userId);
        messenger.showSnackBar(
          const SnackBar(content: Text("Jeu ajouté avec succès !")),
        );
      }
    } catch (e) {
      debugPrint('Failed to add game: $e');
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'ajout du jeu")),
        );
      }
    }
  }

  /// Deletes a game from the user's library, then refreshes the list.
  Future<void> _deleteGame(String gameId) async {
    final authService = context.read<AuthService>();
    final gameService = context.read<GameService>();
    final messenger = ScaffoldMessenger.of(context);
    final userId = authService.currentUser?.id;

    if (userId == null) return;

    try {
      final success = await gameService.deleteUserGame(userId, gameId);
      if (success && mounted) {
        // Refresh the library — Consumer will rebuild automatically.
        await gameService.getUserGames(userId);
        messenger.showSnackBar(
          const SnackBar(content: Text('Jeu retiré de la bibliothèque')),
        );
      }
    } catch (e) {
      debugPrint('Failed to delete game: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté")),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Retour au profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Ajouter un jeu à mon profil'),
            const SizedBox(height: 12),

            // Search row to select a game
            GameSearchRow(
              availableGames: const [],
              selectedGame: _selectedGame,
              onGameSelected: (newValue) => setState(() => _selectedGame = newValue),
              hoursController: _hoursController,
            ),
            const SizedBox(height: 24),

            // Preview of selected game
            if (_selectedGame != null)
              GamePreviewCard(
                game: _selectedGame!,
                onAddPressed: _addGame,
              ),

            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            const SectionTitle(title: 'Jeux ajoutés'),

            // Reacts automatically when GameService notifies listeners.
            Consumer<GameService>(
              builder: (context, gameService, _) {
                if (gameService.isLoadingLibrary) {
                  return const LoadingView(message: "Chargement de vos jeux...");
                }

                if (gameService.userGames.isEmpty) {
                  return const EmptyState(
                    message: "Aucun jeu ajouté pour le moment.",
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gameService.userGames.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final game = gameService.userGames[index];
                    return AddedGameCard(
                      game: GameModel(
                        id: game.idGame.toString(),
                        title: game.name,
                        imageUrl: game.imageUrl,
                      ),
                      hours: game.hours ?? 0,
                      onDelete: () => _deleteGame(game.idGame.toString()),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
