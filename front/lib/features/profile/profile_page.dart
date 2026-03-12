import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/services/game_service.dart';
import 'package:front/models/game_model_detailed.dart';

/// Page de profil de l'utilisateur connecté.
/// Affiche :
///   - L'avatar, le nom d'utilisateur, l'email et le SteamID
///   - Un bouton pour accéder à l'ajout de jeux
///   - La bibliothèque de jeux de l'utilisateur (liste scrollable)
///   - Un bouton de déconnexion
///
/// Cette page est un [StatelessWidget] car l'état de l'utilisateur est géré
/// par [AuthService] via Provider, et la bibliothèque est chargée via [FutureBuilder].
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Écoute les changements d'état de l'AuthService (ex: déconnexion)
    final authService = context.watch<AuthService>();
    final currentUser = authService.currentUser;

    // Extraction des informations de l'utilisateur avec des valeurs par défaut
    final String username = currentUser?['username'] ?? 'Utilisateur';
    final String email = currentUser?['email'] ?? 'Non spécifié';
    // Identifiant Steam de l'utilisateur (null si non lié à un compte Steam)
    final String steamId = currentUser?['steam_id'] ?? 'Non lié';
    // URL de la photo de profil (fallback sur une image placeholder si absente)
    final String avatarUrl = currentUser?['profile_picture'] ?? 'https://picsum.photos/id/237/200/300';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          
          // Avatar de l'utilisateur
          // Avatar circulaire chargé depuis l'URL de la photo de profil
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(height: 24),
          
          // Nom de l'utilisateur
          Text(
            username,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          // Email de l'utilisateur
          Text(
            email,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),

          // Steam ID : intégration du compte Steam
          Text(
            'SteamID: $steamId',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          
          const SizedBox(height: 48),

          // Bouton : ajouter des jeux
          // Navigation vers la sous-route /profile/add_games via go_router
          // L'utilisation de context.go() préserve la barre de navigation du bas
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.go('/profile/add_games');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66c0f4), // Bleu signature Steam
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ajouter des jeux',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Bibliothèque de jeux de l'utilisateur
          // Cette section est affichée uniquement si l'utilisateur est connecté et que son identifiant est disponible
          if (currentUser != null && (currentUser['id_user'] != null || currentUser['id'] != null))
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes Jeux',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<List<GameModelDetailed>>(
                      // Appel asynchrone au service pour charger la bibliothèque de l'utilisateur
                      future: GameService().getUserGames(currentUser['id_user'] ?? currentUser['id']),
                      builder: (context, snapshot) {
                        // En attente de la réponse API
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        // Erreur lors du chargement
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erreur de chargement',
                              style: TextStyle(color: Colors.red[300]),
                            ),
                          );
                        // Aucun jeu dans la bibliothèque
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'Aucun jeu dans la bibliothèque.',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          );
                        }

                        final games = snapshot.data!;
                        // Affichage de la liste de jeux sous forme de cartes
                        return ListView.builder(
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            return Card(
                              color: const Color(0xFF1E2329),
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                // Icône placeholder (l'image est disponible dans la page de détail)
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.sports_esports, color: Colors.white),
                                ),
                                title: Text(
                                  game.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                // Tap : navigation vers la page de détail du jeu (sous /profile/game/:id)
                                onTap: () {
                                  context.push('/profile/game/${game.idGame}');
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Si l'utilisateur n'est pas connecté, on pousse le bouton de déconnexion vers le bas
          if (currentUser == null || (currentUser['id_user'] == null && currentUser['id'] == null))
            const Spacer(),

          // Bouton pour se déconnecter
          // Appel logout() de l'AuthService qui notifie les listeners.
          // GoRouter écoute ces changements via refreshListenable et redirige automatiquement vers /sign-in sans avoir à appeler context.go().
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                final authService = context.read<AuthService>();
                await authService.logout();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Marge de sécurité en bas
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
