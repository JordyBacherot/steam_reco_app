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

          // --------------------------------------------------------------------
          // EXTERNAL INTEGRATION (STEAM ID)
          // --------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SteamID: $steamId',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  final TextEditingController steamIdController = TextEditingController(
                    text: steamId == 'Non lié' ? '' : steamId,
                  );
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: const Text('Modifier Steam ID', style: TextStyle(color: Colors.white)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: steamIdController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Ex: 76561197960287930",
                                hintStyle: TextStyle(color: Colors.white54),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                iconColor: Colors.blueAccent,
                                collapsedIconColor: Colors.blueAccent,
                                title: const Text(
                                  "Où trouver mon Steam ID ?",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: const Text(
                                      "1. Ouvrez Steam et cliquez sur votre pseudo en haut à droite.\n"
                                      "2. Sélectionnez 'Détails du compte'.\n"
                                      "3. Votre 'ID Steam' (une suite de 17 chiffres) se trouve en haut de la page, sous le nom de votre compte.",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66c0f4)),
                            onPressed: () async {
                              final newSteamId = steamIdController.text.trim();
                              if (newSteamId.isNotEmpty) {
                                final success = await context.read<AuthService>().updateSteamId(newSteamId);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Steam ID mis à jour')),
                                  );
                                  Navigator.of(dialogContext).pop();
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Erreur lors de la mise à jour')),
                                  );
                                }
                              }
                            },
                            child: const Text('Sauvegarder', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: Text(steamId == 'Non lié' || steamId.isEmpty ? 'Ajouter' : 'Modifier'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[600]!),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Bouton : ajouter des jeux
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
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
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    game.imageUrl,
                                    width: 100, // Capsule aspect ratio is roughly 2.3:1 (231x87)
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 100,
                                      height: 44,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.videogame_asset, color: Colors.white54),
                                    ),
                                  ),
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
