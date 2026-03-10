import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/core/network/api_client.dart';

/// The [RecoShowPage] displays recommendations based on the `type`
/// passed in the route ('steam' or 'manual').
class RecoShowPage extends StatefulWidget {
  final String type;

  const RecoShowPage({super.key, required this.type});

  @override
  State<RecoShowPage> createState() => _RecoShowPageState();
}

class _RecoShowPageState extends State<RecoShowPage> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _errorMsg = '';
  List<dynamic> _recommendations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecommendations();
    });
  }

  Future<void> _fetchRecommendations() async {
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;
    final userId = currentUser?['id'] ?? currentUser?['id_user'];
    
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
      if (widget.type == 'steam') {
        final steamId = currentUser?['steam_id'];
        if (steamId == null || steamId.toString().isEmpty) {
           throw Exception("Aucun compte Steam lié.");
        }
        
        // Fetch Steam recommendations from the API
        final response = await _apiClient.dio.get('/recommendations/$steamId');
        
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          if (data is Map && data.containsKey('error')) {
             throw Exception(data['error']);
          } else if (data is Map && data.containsKey('recommendations') && data['recommendations'] is List) {
             _recommendations = data['recommendations'];
          } else if (data is List) {
             _recommendations = data;
          } else {
             throw Exception("Format de recommandation inattendu depuis le serveur.");
          }
        }

      } else if (widget.type == 'manual') {
        // 1. Fetch user games to create the payload
        final gamesResponse = await _apiClient.dio.get('/users/$userId/games');
        if (gamesResponse.statusCode != 200) {
           throw Exception("Impossible de récupérer la liste des jeux.");
        }
        
        final List<dynamic> userGamesData = gamesResponse.data['data'] ?? [];
        if (userGamesData.length < 3) {
            throw Exception("Pas assez de jeux manuels pour générer une recommandation (minimum 3).");
        }

        // 2. Map local games into the GameItem interface required by POST /recommendations/manual
        final List<Map<String, dynamic>> payloadGames = userGamesData.map((item) {
           final gameData = item['game'] ?? {};
           final int gameId = item['id_game'] ?? gameData['id_game'] ?? 0;
           final int hours = item['nb_hours'] ?? 0;
           return {
             "game_id": gameId,
             "hours": hours
           };
        }).toList();

        // 3. Request recommendations based on manual games
        final manualResponse = await _apiClient.dio.post(
           '/recommendations/manual', 
           data: {
             "games": payloadGames,
             "limit": 10
           }
        );
        
        if (manualResponse.statusCode == 200 && manualResponse.data != null) {
           final data = manualResponse.data;
           if (data is Map && data.containsKey('error')) {
              throw Exception(data['error']);
           } else if (data is Map && data.containsKey('recommendations') && data['recommendations'] is List) {
              _recommendations = data['recommendations'];
           } else if (data is List) {
              _recommendations = data;
           } else {
              throw Exception("Format de recommandation inattendu depuis le serveur.");
           }
        }
        
      } else {
        throw Exception("Type de recommandation inconnu.");
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Recommendation fetch error: $e");
      if (mounted) {
        setState(() {
          _errorMsg = "Une erreur est survenue lors de la récupération des recommandations.\nAssurez-vous que l'API Python est bien lancée et accessible.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1b2838), // Steam dark background
      appBar: AppBar(
        title: const Text('Vos Recommandations'),
        backgroundColor: const Color(0xFF171a21),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Color(0xFF66c0f4)),
            SizedBox(height: 24),
            Text(
              "Analyse en cours...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            )
          ],
        ),
      );
    }

    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
              const SizedBox(height: 16),
              Text(
                _errorMsg,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMsg = '';
                  });
                  _fetchRecommendations();
                },
                child: const Text('Réessayer'),
              )
            ],
          ),
        ),
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
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          "Voici ce que notre IA vous a sélectionné",
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 24),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recommendations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final reco = _recommendations[index];
            
            // Depending on the python API returning structure, 
            // map it to a standard object. Assuming it returns at least 'name' and 'game_id'.
            final String name = reco['name'] ?? reco['title'] ?? 'Jeu inconnu';
            final String? image = reco['image_url'] ?? reco['header_image'];
            final String desc = reco['description'] ?? reco['short_description'] ?? 'Pas de description';
            
            return Card(
              color: const Color(0xFF171a21),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Image Cover
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: image != null
                          ? Image.network(
                              image,
                              width: 120,
                              height: 65,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 120,
                                height: 65,
                                color: Colors.grey[800],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            )
                          : Container(
                              width: 120,
                              height: 65,
                              color: Colors.grey[800],
                              child: const Icon(Icons.videogame_asset, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            desc,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
