import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:front/services/game_service.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/models/near_game_model.dart';
import 'package:front/shared/widgets/status_views.dart';

import 'game_image.dart';
import 'game_header_widget.dart';
import 'similar_games_list.dart';
import 'game_reviews_widget.dart';

class GamePages extends StatefulWidget {
  final String gameId;
  const GamePages({super.key, required this.gameId});

  @override
  State<GamePages> createState() => _GamePagesState();
}

class _GamePagesState extends State<GamePages> {
  bool _isLoading = true;
  String? _errorMessage;
  GameModelDetailed? _gameDetails;
  List<NearGameModel> _similarGames = [];

  @override
  void initState() {
    super.initState();
    _fetchGameData();
  }

  @override
  void didUpdateWidget(covariant GamePages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameId != widget.gameId) {
      _fetchGameData();
    }
  }

  Future<void> _fetchGameData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final gameIdAsInt = int.tryParse(widget.gameId);
    if (gameIdAsInt == null) {
      _showError("Identifiant de jeu invalide.");
      return;
    }

    try {
      final gameService = context.read<GameService>();
      final details = await gameService.getGameById(gameIdAsInt);
      
      if (details == null) {
        _showError("Jeu introuvable sur le serveur.");
        return;
      }

      List<NearGameModel> recommendations = [];
      try {
        recommendations = await gameService.getNearestGames(widget.gameId)
            .timeout(const Duration(seconds: 5), onTimeout: () => []);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _gameDetails = details;
          _similarGames = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError("Erreur inattendue: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        resizeToAvoidBottomInset: false, 
        body: LoadingView(message: "Chargement..."),
      );
    }

    if (_errorMessage != null || _gameDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: ErrorView(
          message: _errorMessage ?? "Erreur inconnue",
          onRetry: _fetchGameData,
        ),
      );
    }

    final game = _gameDetails!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(game.name.isNotEmpty ? game.name : "Jeu #${game.idGame}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GameHeroImage(imageUrl: game.imageUrl),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GameHeaderWidget(game: game),
                  
                  const SizedBox(height: 16),
                  Text(
                    game.description ?? "Aucune description disponible.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  
                  SimilarGamesList(similarGames: _similarGames),
                  
                  GameReviewsWidget(gameId: game.idGame),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}