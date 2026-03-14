import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/services/recommendation_service.dart';
import 'package:front/shared/widgets/game_card.dart';
import 'package:front/shared/widgets/game_list.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:front/shared/widgets/status_views.dart';
import 'package:go_router/go_router.dart';

/// Displays a list of games suggested for a specific recommendation type.
class RecoShowPage extends StatefulWidget {
  /// The recommendation category (e.g., 'steam', 'manual').
  final String type;

  const RecoShowPage({super.key, required this.type});

  @override
  State<RecoShowPage> createState() => _RecoShowPageState();
}

/// State for [RecoShowPage] responsible for fetching and displaying results.
class _RecoShowPageState extends State<RecoShowPage> {
  bool _isLoading = true;
  String _errorMsg = '';
  List<dynamic> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    final userId = currentUser?.id;
    
    if (userId == null) {
      if (mounted) {
        setState(() {
          _errorMsg = "Utilisateur non authentifié.";
          _isLoading = false;
        });
      }
      return;
    }

    try {
      List<dynamic> results;
      if (widget.type == 'steam') {
        final steamId = currentUser?.steamId;
        if (steamId == null || steamId.isEmpty) {
           throw Exception("Aucun compte Steam lié.");
        }
        results = await Provider.of<RecommendationService>(context, listen: false).getSteamRecommendations(steamId);
      } else if (widget.type == 'manual') {
        results = await Provider.of<RecommendationService>(context, listen: false).getManualRecommendations(userId);
      } else {
        throw Exception("Type de recommandation inconnu.");
      }
      
      if (mounted) {
        setState(() {
          _recommendations = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().contains("Exception:") 
              ? e.toString().split("Exception:").last.trim()
              : "Une erreur est survenue lors de la récupération des recommandations.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Vos Recommandations'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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

    final String title = widget.type == 'steam' 
        ? "Générées depuis votre compte Steam" 
        : "Générées depuis votre bibliothèque interne";

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        SectionTitle(title: title),
        const SizedBox(height: 4),
        Text(
          "Voici ce que notre IA vous a sélectionné",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        
        GameList(
          games: _recommendations,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          spacing: 16,
          emptyMessage: "Aucun jeu recommandé trouvé.",
          cardBuilder: (context, reco) {
            final String name = reco['name'] ?? reco['title'] ?? 'Jeu inconnu';
            final int? appid = reco['appid'] is int
                ? reco['appid']
                : int.tryParse(reco['appid']?.toString() ?? '');
            final String? rawImage = reco['image_url'] ?? reco['header_image'];
            
            final String? image = (rawImage == null || rawImage.isEmpty || rawImage.contains('picsum.photos'))
                ? (appid != null ? 'https://cdn.akamai.steamstatic.com/steam/apps/$appid/capsule_231x87.jpg' : null)
                : rawImage;

            final String desc = reco['description'] ?? reco['short_description'] ?? 'Pas de description';
            
            return GameCard(
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
            );
          },
        ),
      ],
    );
  }
}