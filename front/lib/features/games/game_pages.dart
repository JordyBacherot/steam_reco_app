import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:front/services/game_service.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/models/near_game_model.dart';
import 'package:front/shared/widgets/status_views.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/models/review_model.dart';
import 'package:front/services/auth_service.dart';

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
  List<ReviewModel> _reviews = [];
  final TextEditingController _reviewController = TextEditingController();
  bool _isPostingReview = false;

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
          _errorMessage = "Invalid ID";
          _isLoading = false;
        });
        return;
      }

      final details = await Provider.of<GameService>(context, listen: false)
          .getGameById(intId);
      if (details == null) {
        setState(() {
          _errorMessage = "Game not found in API";
          _isLoading = false;
        });
        return;
      }

      List<NearGameModel> recos = [];
      try {
        recos = await Provider.of<GameService>(context, listen: false)
            .getNearestGames(details.name)
            .timeout(const Duration(seconds: 5), onTimeout: () => []);
      } catch (_) {}

      List<ReviewModel> reviews = [];
      try {
        reviews = await Provider.of<GameService>(context, listen: false)
            .getReviewsForGame(intId);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _gameDetails = details;
          _nearestGames = recos;
          _reviews = reviews;
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

  Future<void> _postReview() async {
    final text = _reviewController.text.trim();
    if (text.isEmpty) return;

    if (text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("L'avis doit faire au moins 2 caractères.")),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    setState(() => _isPostingReview = true);
    try {
      final success =
          await Provider.of<GameService>(context, listen: false).postReview(
        gameId: int.parse(widget.gameId),
        userId: authService.currentUser!.id,
        text: text,
      );

      if (success) {
        _reviewController.clear();
        final updatedReviews =
            await Provider.of<GameService>(context, listen: false)
                .getReviewsForGame(int.parse(widget.gameId));
        if (mounted) {
          setState(() => _reviews = updatedReviews);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de l'envoi de l'avis.")),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isPostingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(
          resizeToAvoidBottomInset: false,
          body: LoadingView(message: "Loading..."));

    if (_errorMessage != null || _gameDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: ErrorView(
          message: _errorMessage ?? "Unknown error",
          onRetry: _fetchGameData,
        ),
      );
    }

    final game = _gameDetails!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(game.name.isNotEmpty ? game.name : "Game #${game.idGame}"),
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
                    game.description ?? "No description available.",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5),
                  ),
                  if (_nearestGames.isNotEmpty) _buildSimilarGames(),
                  _buildReviewsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    final authService = Provider.of<AuthService>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "Avis des joueurs :",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (authService.isAuthenticated) _buildPostReviewInput(),
        const SizedBox(height: 24),
        if (_reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Aucun avis pour le moment. Soyez le premier à en poster un !",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          )
        else
          ..._reviews.map((review) => _buildReviewItem(review)),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPostReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _reviewController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Écrivez votre avis ici...",
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF171a21),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryBlue),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _isPostingReview ? null : _postReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isPostingReview
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text("Poster l'avis"),
        ),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1b2838),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: AppTheme.primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                review.username,
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.text,
            style: const TextStyle(
                color: Colors.white70, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "Jeux similaires :",
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
        child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
      ),
    );
  }
}
