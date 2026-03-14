import 'package:flutter/material.dart';
import 'package:front/models/game_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/features/profile/widgets/game_search_row.dart';
import 'package:front/features/profile/widgets/game_preview_card.dart';
import 'package:front/features/profile/widgets/added_game_card.dart';
import 'package:front/services/game_service.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:front/shared/widgets/empty_state.dart';
import 'package:front/shared/widgets/status_views.dart';

/// A page where users can search for and add games to their personal library.
class AddGamesPage extends StatefulWidget {
  const AddGamesPage({super.key});

  @override
  State<AddGamesPage> createState() => _AddGamesPageState();
}

/// State for [AddGamesPage] managing game search, addition, and library synchronization.
class _AddGamesPageState extends State<AddGamesPage> {
  bool _isLoading = true;

  // List of games already added by the user (fetched from backend)
  List<Map<String, dynamic>> _addedGames = [];

  GameModel? _selectedGame;
  final TextEditingController _hoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await _fetchUserGames();
  }

  Future<void> _fetchUserGames() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;
    
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final games = await Provider.of<GameService>(context, listen: false).getUserGames(userId);
      
      final List<Map<String, dynamic>> mappedGames = games.map((game) {
        return {
          'game': GameModel(
            id: game.idGame.toString(),
            title: game.name,
            imageUrl: game.imageUrl,
          ),
          'hours': 0, // Note: getUserGames currently doesn't return hours in GameModelDetailed
                      // We might want to fix this in GameService/GameModelDetailed later
        };
      }).toList();

      if (mounted) {
        setState(() {
          _addedGames = mappedGames;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load user games: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addGame() async {
    if (_selectedGame != null && _hoursController.text.isNotEmpty) {
      final hours = int.tryParse(_hoursController.text);
      if (hours != null && hours >= 0) {
        final authService = context.read<AuthService>();
        final messenger = ScaffoldMessenger.of(context);
        final userId = authService.currentUser?.id;

        if (userId == null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
          );
          return;
        }

        try {
          final success = await Provider.of<GameService>(context, listen: false).addUserGame(
            userId: userId,
            gameId: int.parse(_selectedGame!.id),
            hours: hours,
            gameTitle: _selectedGame!.title,
            gameImageUrl: _selectedGame!.imageUrl,
          );

          if (success) {
            await _fetchUserGames();
            authService.fetchUserGamesCount();

            if (mounted) {
              setState(() {
                _selectedGame = null;
                _hoursController.clear();
              });
              messenger.showSnackBar(
                const SnackBar(content: Text("Jeu ajouté avec succès !")),
              );
            }
          }
        } catch (e) {
          debugPrint('Failed to add game: $e');
          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(content: Text("Erreur lors de l'ajout du jeu")),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez entrer un nombre d'heures valide")),
        );
      }
    }
  }

  Future<void> _deleteGame(String gameId) async {
    final authService = context.read<AuthService>();
    final messenger = ScaffoldMessenger.of(context);
    final userId = authService.currentUser?.id;

    if (userId == null) return;

    try {
      final success = await Provider.of<GameService>(context, listen: false).deleteUserGame(userId, gameId);
      if (success) {
        authService.fetchUserGamesCount();

        if (mounted) {
          setState(() {
            _addedGames.removeWhere((item) => (item['game'] as GameModel).id == gameId);
          });
          messenger.showSnackBar(
            const SnackBar(content: Text('Jeu retiré de la bibliothèque')),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to delete game: $e');
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Retour au profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading 
        ? const LoadingView(message: "Chargement de vos jeux...")
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Ajouter un jeu à mon profil'),
            const SizedBox(height: 12),

            GameSearchRow(
              availableGames: const [],
              selectedGame: _selectedGame,
              onGameSelected: (newValue) {
                setState(() {
                  _selectedGame = newValue;
                });
              },
              hoursController: _hoursController,
            ),
            const SizedBox(height: 24),

            if (_selectedGame != null) 
              GamePreviewCard(
                game: _selectedGame!,
                onAddPressed: _addGame,
              ),

            const Divider(color: Colors.grey),
            const SizedBox(height: 8),

            const SectionTitle(title: 'Jeux ajoutés'),

            if (_addedGames.isEmpty)
              const EmptyState(
                message: "Aucun jeu ajouté pour le moment.",
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _addedGames.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _addedGames[index];
                  final GameModel game = item['game'];
                  final int hours = item['hours'];

                  return AddedGameCard(
                    game: game,
                    hours: hours,
                    onDelete: () => _deleteGame(game.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
