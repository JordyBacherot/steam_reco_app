import 'package:flutter/material.dart';
import 'package:front/models/game_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/core/network/api_client.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/features/profile/widgets/game_search_row.dart';
import 'package:front/features/profile/widgets/game_preview_card.dart';
import 'package:front/features/profile/widgets/added_game_card.dart';

class AddGamesPage extends StatefulWidget {
  const AddGamesPage({super.key});

  @override
  State<AddGamesPage> createState() => _AddGamesPageState();
}

class _AddGamesPageState extends State<AddGamesPage> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  // List of games already added by the user (fetched from backend)
  List<Map<String, dynamic>> _addedGames = [];

  GameModel? _selectedGame;
  final TextEditingController _hoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  Future<void> _fetchInitialData() async {
    await _fetchUserGames();
  }

  Future<void> _fetchUserGames() async {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?['id'] ?? authService.currentUser?['id_user'];
    
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _apiClient.dio.get('/users/$userId/games');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        final List<Map<String, dynamic>> mappedGames = data.map((item) {
          final gameData = item['game'] ?? {};
          final gameModel = GameModel(
            id: gameData['id_game']?.toString() ?? item['id_game'].toString(),
            title: gameData['name'] ?? 'Jeu inconnu',
            imageUrl: gameData['image_url'] ?? 'https://picsum.photos/id/237/200/300',
          );
          return {
            'game': gameModel,
            'hours': item['nb_hours'],
          };
        }).toList();

        if (mounted) {
          setState(() {
            _addedGames = mappedGames;
            _isLoading = false;
          });
        }
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
        // Capture context-dependent objects BEFORE any await
        final authService = context.read<AuthService>();
        final messenger = ScaffoldMessenger.of(context);
        final userId = authService.currentUser?['id'] ?? authService.currentUser?['id_user'];

        if (userId == null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
          );
          return;
        }

        try {
          final response = await _apiClient.dio.post(
            '/users/$userId/games',
            data: {
              'id_game': int.parse(_selectedGame!.id),
              'nb_hours': hours,
              'game_title': _selectedGame!.title,
              'game_image_url': _selectedGame!.imageUrl,
            },
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
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
    // Capture context-dependent objects BEFORE any await
    final authService = context.read<AuthService>();
    final messenger = ScaffoldMessenger.of(context);
    final userId = authService.currentUser?['id'] ?? authService.currentUser?['id_user'];

    if (userId == null) return;

    try {
      final response = await _apiClient.dio.delete('/users/$userId/games/$gameId');
      if (response.statusCode == 200) {
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
      backgroundColor: const Color(0xFF1b2838), // Steam dark background
      appBar: AppBar(
        title: const Text('Retour au profil'),
        backgroundColor: const Color(0xFF171a21),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF66c0f4)))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Ajouter un jeu à mon profil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 24),

            // Dropdown and Rating Row
            GameSearchRow(
              availableGames: const [], // Not used anymore by GameSearchRow
              selectedGame: _selectedGame,
              onGameSelected: (newValue) {
                setState(() {
                  _selectedGame = newValue;
                });
              },
              hoursController: _hoursController,
            ),
            const SizedBox(height: 24),

            // Preview Card (Shown only if a game is selected)
            if (_selectedGame != null) 
              GamePreviewCard(
                game: _selectedGame!,
                onAddPressed: _addGame,
              ),

            const Divider(color: Colors.grey),
            const SizedBox(height: 24),

            // Title: Jeux ajoutés
            Text(
              'Jeux ajoutés',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),

            // List of added games
            if (_addedGames.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "Aucun jeu ajouté pour le moment.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
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
