import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/services/game_service.dart';
import 'package:front/models/game_model_detailed.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/shared/widgets/game_card.dart';
import 'package:front/shared/widgets/game_list.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:front/shared/widgets/status_views.dart';
import 'package:front/features/profile/widgets/profile_header.dart';

/// The user's profile page showing their personal information and game library.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    final String username = currentUser?.username ?? 'Utilisateur';
    final String email = currentUser?.email ?? 'Non spécifié';
    final String steamId = currentUser?.steamId ?? 'Non lié';
    final String avatarUrl = currentUser?.profilePicture ?? 'https://picsum.photos/id/237/200/300';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileHeader(
            username: username,
            email: email,
            steamId: steamId,
            avatarUrl: avatarUrl,
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go('/profile/add_games'),
                child: const Text('Ajouter des jeux'),
              ),
            ),
          ),
          
          if (currentUser != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'Mes Jeux', topPadding: 16),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<List<GameModelDetailed>>(
                      future: Provider.of<GameService>(context, listen: false).getUserGames(currentUser.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const LoadingView(message: "Chargement de la bibliothèque...");
                        } else if (snapshot.hasError) {
                          return ErrorView(
                            message: "Erreur de chargement de la bibliothèque",
                            onRetry: () => (context as Element).markNeedsBuild(),
                          );
                        }

                        final games = snapshot.data ?? [];
                        return GameList(
                          games: games,
                          emptyMessage: 'Aucun jeu dans la bibliothèque.',
                          cardBuilder: (context, game) {
                            final g = game as GameModelDetailed;
                            return GameCard(
                              name: g.name,
                              description: g.hours != null ? "${g.hours} heures jouées" : "Dans votre bibliothèque",
                              imageUrl: g.imageUrl,
                              gameId: g.idGame,
                              onTap: () => context.push('/profile/game/${g.idGame}'),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          if (currentUser == null)
            const Spacer(),

          const SizedBox(height: 32), // Added space before logout

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.read<AuthService>().logout();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
              ),
              child: const Text('SE DÉCONNECTER'),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
