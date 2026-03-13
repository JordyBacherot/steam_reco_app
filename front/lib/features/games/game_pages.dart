import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:front/services/game_service.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/models/near_game_model.dart';
import 'package:front/shared/widgets/status_views.dart';
import 'package:front/core/theme/app_theme.dart';

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
  List<NearGameModel> _nearestGames = [];

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

    try {
      final intId = int.tryParse(widget.gameId);
      if (intId == null) {
        setState(() {
          _errorMessage = "ID invalide";
          _isLoading = false;
        });
        return;
      }

      final details = await Provider.of<GameService>(context, listen: false).getGameById(intId);
      if (details == null) {
        setState(() {
          _errorMessage = "Jeu introuvable dans l'API";
          _isLoading = false;
        });
        return;
      }

      List<NearGameModel> recos = [];
      try {
        recos = await Provider.of<GameService>(context, listen: false).getNearestGames(intId)
            .timeout(const Duration(seconds: 5), onTimeout: () => []);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _gameDetails = details;
          _nearestGames = recos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(resizeToAvoidBottomInset: false, body: LoadingView(message: "Chargement..."));

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
            _buildHeroImage(game.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (game.studio?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Text(
                      game.studio!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (game.meanReview != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${(game.meanReview! * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 16, 
                        color: Colors.white70, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    game.description ?? "Pas de description disponible.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  if (_nearestGames.isNotEmpty) _buildSimilarGames(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "Jeux Similaires :",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ..._nearestGames.map((nearGame) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              final location = GoRouterState.of(context).matchedLocation;
              if (location.startsWith('/profile')) {
                context.push('/profile/game/${nearGame.appid}');
              } else if (location.startsWith('/reco')) {
                context.push('/reco/game/${nearGame.appid}');
              } else {
                context.push('/game/${nearGame.appid}');
              }
            },
            child: Text(
              "→ ${nearGame.name} (${(nearGame.score * 100).toStringAsFixed(0)}%)",
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

  Widget _buildHeroImage(String imageUrl) {
    return Image.network(
      imageUrl,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 250,
        color: const Color(0xFF171a21),
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
      ),
    );
  }
}