import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/services/game_service.dart';
import 'package:front/services/recommendation_service.dart';
import 'package:front/shared/widgets/game_card.dart';
import 'package:front/shared/widgets/status_views.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:go_router/go_router.dart';

/// Displays a list of games suggested for a specific recommendation type.
class RecoShowPage extends StatefulWidget {
  /// The recommendation category (e.g., 'steam' or 'manual').
  final String type;

  const RecoShowPage({super.key, required this.type});

  @override
  State<RecoShowPage> createState() => _RecoShowPageState();
}

class _RecoShowPageState extends State<RecoShowPage> {
  bool _isLoading = true;
  String _errorMsg = '';
  List<dynamic> _recommendations = [];

  // Cached reference so we can safely remove the listener in dispose()
  // without touching context, which is invalid at that point.
  late final GameService _gameService;

  @override
  void initState() {
    super.initState();
    _gameService = context.read<GameService>();
    // If the library is still being fetched (initiated by RecoPage),
    // wait for it to finish before calling the recommendation endpoint.
    if (_gameService.isLoadingLibrary) {
      _gameService.addListener(_onLibraryReady);
    } else {
      _fetchRecommendations();
    }
  }

  /// Called each time GameService notifies. Proceeds once loading is done.
  void _onLibraryReady() {
    if (!_gameService.isLoadingLibrary) {
      _gameService.removeListener(_onLibraryReady);
      _fetchRecommendations();
    }
  }

  @override
  void dispose() {
    // Safe: uses the cached reference, not context.
    _gameService.removeListener(_onLibraryReady);
    super.dispose();
  }

  String? getFullImageUrl(String? appid) {
    if (appid == null || appid.isEmpty) return null;
    return 'https://cdn.akamai.steamstatic.com/steam/apps/$appid/capsule_184x69.jpg';
  }

  /// Fetches recommendations depending on type (Steam or manual).
  Future<void> _fetchRecommendations() async {
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      setState(() {
        _errorMsg = "Utilisateur non authentifié.";
        _isLoading = false;
      });
      return;
    }

    try {
      final recoService = context.read<RecommendationService>();

      if (widget.type == 'steam') {
        final steamId = currentUser.steamId;
        if (steamId == null || steamId.isEmpty) {
          throw Exception("Aucun compte Steam lié.");
        }
        _recommendations = await recoService.getSteamRecommendations(steamId);
      } else if (widget.type == 'manual') {
        _recommendations = await recoService.getManualRecommendations(currentUser.id);
      } else {
        throw Exception("Type de recommandation inconnu.");
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always wrap in Scaffold so LoadingView / ErrorView have proper height constraints.
    if (_isLoading) {
      return const Scaffold(
        body: LoadingView(),
      );
    }

    if (_errorMsg.isNotEmpty) {
      return Scaffold(
        body: ErrorView(
          message: _errorMsg,
          onRetry: () {
            setState(() {
              _isLoading = true;
              _errorMsg = '';
            });
            _fetchRecommendations();
          },
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Aucun jeu recommandé trouvé.",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      );
    }

    final title = widget.type == 'steam'
        ? "Générées depuis votre compte Steam"
        : "Générées depuis votre bibliothèque interne";

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _recommendations.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) return SectionTitle(title: title);

          if (index == 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 24),
              child: Text(
                "Voici ce que notre IA vous a sélectionné",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          final reco = _recommendations[index - 2];
          final int? appid = reco['appid'] is int
              ? reco['appid']
              : int.tryParse(reco['appid']?.toString() ?? '');
          final String? image =
              appid != null ? getFullImageUrl(appid.toString()) : null;
          final String desc = reco['description'] ??
              reco['short_description'] ??
              'Pas de description';
          final String name = reco['name'] ?? reco['title'] ?? 'Jeu inconnu';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GameCard(
              name: name,
              description: desc,
              imageUrl: image,
              gameId: appid,
              onTap: () {
                if (appid != null) {
                  context.push('/reco/game/$appid');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Détails indisponibles pour ce jeu.")),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}