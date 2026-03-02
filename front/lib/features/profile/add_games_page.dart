import 'package:flutter/material.dart';
import 'package:front/features/main/models/game_model.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/profile/widgets/game_search_row.dart';
import 'package:front/features/profile/widgets/game_preview_card.dart';
import 'package:front/features/profile/widgets/added_game_card.dart';

class AddGamesPage extends StatefulWidget {
  const AddGamesPage({super.key});

  @override
  State<AddGamesPage> createState() => _AddGamesPageState();
}

class _AddGamesPageState extends State<AddGamesPage> {
  // Fake game database for the dropdown
  final List<GameModel> _availableGames = [
    const GameModel(
      title: 'The Witcher 3: Wild Hunt',
      imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/292030/capsule_231x87.jpg',
    ),
    const GameModel(
      title: 'Portal 2',
      imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/620/capsule_231x87.jpg',
    ),
    const GameModel(
      title: 'Terraria',
      imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/105600/capsule_231x87.jpg',
    ),
    const GameModel(
      title: 'Left 4 Dead 2',
      imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/550/capsule_231x87.jpg',
    ),
  ];

  // List of games already added by the user
  final List<Map<String, dynamic>> _addedGames = [];

  GameModel? _selectedGame;
  final TextEditingController _ratingController = TextEditingController();

  void _addGame() {
    if (_selectedGame != null && _ratingController.text.isNotEmpty) {
      final rating = int.tryParse(_ratingController.text);
      if (rating != null && rating >= 0 && rating <= 5) {
        setState(() {
          _addedGames.add({
            'game': _selectedGame,
            'rating': rating,
          });
          // Reset selection
          _selectedGame = null;
          _ratingController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer une note valide entre 0 et 5')),
        );
      }
    }
  }

  @override
  void dispose() {
    _ratingController.dispose();
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
      body: SingleChildScrollView(
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
              availableGames: _availableGames,
              selectedGame: _selectedGame,
              onGameSelected: (newValue) {
                setState(() {
                  _selectedGame = newValue;
                });
              },
              ratingController: _ratingController,
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
                  final int rating = item['rating'];

                  return AddedGameCard(
                    game: game,
                    rating: rating,
                    onDelete: () {
                      setState(() {
                        _addedGames.removeAt(index);
                      });
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
