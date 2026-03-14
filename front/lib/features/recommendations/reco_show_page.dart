import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
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

/// State for [RecoShowPage] responsible for fetching and displaying recommendations.
class _RecoShowPageState extends State<RecoShowPage> {
  bool _isLoading = true;
  String _errorMsg = '';
  List<dynamic> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  /// Fetches recommendations depending on type (Steam or manual)
  Future<void> _fetchRecommendations() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      setState(() {
        _errorMsg = "Utilisateur non authentifié.";
        _isLoading = false;
      });
      return;
    }

    try {
      // Steam requires non-null steamId
      if (widget.type == 'steam') {
        final steamId = currentUser.steamId;
        if (steamId == null || steamId.isEmpty) {
          throw Exception("Aucun compte Steam lié.");
        }
        _recommendations = await Provider.of<RecommendationService>(context, listen: false)
            .getSteamRecommendations(steamId);
      } else if (widget.type == 'manual') {
        final userId = currentUser.id; // int, correct type
        _recommendations = await Provider.of<RecommendationService>(context, listen: false)
            .getManualRecommendations(userId);
      } else {
        throw Exception("Type de recommandation inconnu.");
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();

    if (_errorMsg.isNotEmpty) {
      return ErrorView(
        message: _errorMsg,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _errorMsg = '';
          });
          _fetchRecommendations();
        },
      );
    }

    if (_recommendations.isEmpty) {
      return const Center(
        child: Text(
          "Aucun jeu recommandé trouvé.",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    final title = widget.type == 'steam'
        ? "Générées depuis votre compte Steam"
        : "Générées depuis votre bibliothèque interne";

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _recommendations.length + 2,
      itemBuilder: (context, index) {
        // Title
        if (index == 0) return SectionTitle(title: title);

        // Subtitle
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            child: Text(
              "Voici ce que notre IA vous a sélectionné",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        // Remaining items: recommendation cards
        final reco = _recommendations[index - 2]; // adjust for header
        final int? appid = reco['appid'] is int
            ? reco['appid']
            : int.tryParse(reco['appid']?.toString() ?? '');
        final String? rawImage = reco['image_url'] ?? reco['header_image'];
        final String? image = rawImage?.isEmpty == true ? null : rawImage;
        final String desc = reco['description'] ?? reco['short_description'] ?? 'Pas de description';
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
                  const SnackBar(content: Text("Détails indisponibles pour ce jeu.")),
                );
              }
            },
          ),
        );
      },
    );
  }
}