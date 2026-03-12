import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:front/services/game_service.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/models/near_game_model.dart';

/// Page de détail d'un jeu.
/// Reçoit un [gameId] (String) depuis la route GoRouter et affiche :
///   - L'image de couverture du jeu
///   - Son nom et sa description
///   - La liste des jeux similaires cliquables
class GamePages extends StatefulWidget {
  /// Identifiant du jeu transmis par le paramètre de route (:id)
  final String gameId;

  const GamePages({super.key, required this.gameId});

  @override
  State<GamePages> createState() => _GamePagesState();
}

class _GamePagesState extends State<GamePages> {
  final GameService _gameService = GameService();

  /// Indique si les données sont en cours de chargement
  bool _isLoading = true;

  /// Message d'erreur à afficher si le chargement échoue
  String? _errorMessage;

  /// Données complètes du jeu une fois chargées
  GameModelDetailed? _gameDetails;

  /// Liste des jeux similaires recommandés
  List<NearGameModel> _nearestGames = [];

  @override
  void initState() {
    super.initState();
    // Lancement du chargement des données au démarrage du widget
    _fetchGameData();
  }

  @override
  void didUpdateWidget(covariant GamePages oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si l'utilisateur navigue vers un autre jeu (ex: jeu similaire),
    // le gameId change et on recharge les données automatiquement
    if (oldWidget.gameId != widget.gameId) {
      _fetchGameData();
    }
  }

  /// Charge les données du jeu et ses jeux similaires depuis l'API.
  Future<void> _fetchGameData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Conversion du gameId (String) en entier
      final intId = int.tryParse(widget.gameId);
      if (intId == null) {
        setState(() => { _errorMessage = "ID invalide", _isLoading = false });
        return;
      }

      // Récupération des détails du jeu via l'API
      final details = await _gameService.getGameById(intId);
      if (details == null) {
        setState(() => { _errorMessage = "Jeu introuvable dans l'API", _isLoading = false });
        return;
      }

      // Récupération des jeux similaires (erreur silencieuse : la page reste fonctionnelle)
      List<NearGameModel> recos = [];
      try { recos = await _gameService.getNearestGames(intId); } catch (_) {}

      // Mise à jour de l'état uniquement si le widget est encore monté
      if (mounted) {
        setState(() {
          _gameDetails = details;
          _nearestGames = recos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => { _errorMessage = "Erreur: $e", _isLoading = false });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Affichage d'un indicateur de chargement pendant la récupération des données
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1b2838),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Affichage d'une page d'erreur si le chargement a échoué
    if (_errorMessage != null || _gameDetails == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1b2838),
        appBar: AppBar(
          backgroundColor: const Color(0xFF171a21),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Erreur", style: TextStyle(color: Colors.white)),
        ),
        body: Center(child: Text(_errorMessage ?? "Erreur", style: const TextStyle(color: Colors.red))),
      );
    }

    final game = _gameDetails!;

    return Scaffold(
      backgroundColor: const Color(0xFF1b2838),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171a21),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // Titre : nom du jeu, ou son ID si le nom est vide (sécurité)
        title: Text(
          game.name.isNotEmpty ? game.name : "Jeu #${game.idGame}",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture en haut de la page
            _buildHeroImage(game.imageUrl),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre du jeu (affiché également dans le corps pour la lisibilité)
                  Text(
                    game.name.isNotEmpty ? game.name : "⚠️ NOM MANQUANT DANS L'API",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),

                  // Studio développeur (affiché uniquement s'il est renseigné)
                  if (game.studio != null && game.studio!.isNotEmpty)
                    Text(
                      game.studio!,
                      style: const TextStyle(fontSize: 14, color: Colors.white54, fontStyle: FontStyle.italic),
                    ),

                  const SizedBox(height: 8),

                  // Note moyenne des reviews (affichée uniquement si elle existe)
                  if (game.meanReview != null)
                    Text(
                      '${(game.meanReview! * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w600),
                    ),

                  const SizedBox(height: 16),
                  
                  // Description du jeu
                  Text(
                    (game.description != null && game.description!.isNotEmpty) 
                        ? game.description! 
                        : "⚠️ Aucune description renvoyée par l'API.",
                    style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5),
                  ),

                  // Section "Jeux Similaires" : visible uniquement si des recommandations existent
                  if (_nearestGames.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text(
                      "Jeux Similaires :",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    
                    // Liste de textes cliquables pour chaque jeu similaire
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _nearestGames.map((nearGame) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () {
                              // Navigation contextuelle : on pousse la route appropri selon qu'on est dans le branch /profile ou /home
                              final location = GoRouterState.of(context).matchedLocation;
                              if (location.startsWith('/profile')) {
                                context.push('/profile/game/${nearGame.appid}');
                              } else {
                                context.push('/game/${nearGame.appid}');
                              }
                            },
                            child: Text(
                              "→ ${nearGame.name} (${(nearGame.score * 100).toStringAsFixed(0)}%)",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF66c0f4), // Bleu style lien Steam
                                decoration: TextDecoration.underline, // Souligné pour indiquer que c'est cliquable
                                decorationColor: Color(0xFF66c0f4),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le widget d'image de couverture en haut de la page.
  /// Utilise [CachedNetworkImage] pour la mise en cache et le chargement optimisé.
  /// Affiche un conteneur de remplacement si l'URL est vide ou invalide.
  Widget _buildHeroImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(height: 250, color: const Color(0xFF171a21), child: const Center(child: Text("Pas d'image", style: TextStyle(color: Colors.grey))));
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      // Widget affiché si l'image ne peut pas être chargée
      errorWidget: (context, url, error) => Container(height: 250, color: const Color(0xFF171a21), child: const Center(child: Text("Image cassée", style: TextStyle(color: Colors.grey)))),
    );
  }
}