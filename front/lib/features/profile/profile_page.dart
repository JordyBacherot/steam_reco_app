import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';

/// The [ProfilePage] displays the current user's profile information, including
/// their avatar, username, email, and SteamID. It also provides primary actions 
/// to add new games to their collection or log out of the application.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final currentUser = authService.currentUser;

    final String username = currentUser?['username'] ?? 'Utilisateur';
    final String email = currentUser?['email'] ?? 'Non spécifié';
    // Use the actual steam_id column if present, else fallback
    final String steamId = currentUser?['steam_id'] ?? 'Non lié';
    // Use the actual profile_picture if present, else default to a placeholder
    final String avatarUrl = currentUser?['profile_picture'] ?? 'https://picsum.photos/id/237/200/300';

    return Padding(
      // Surround the entire vertical layout with generous padding
      padding: const EdgeInsets.all(24.0),
      child: Column(
        // Center all children horizontally within the column
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          
          // --------------------------------------------------------------------
          // USER AVATAR
          // --------------------------------------------------------------------
          // Circular avatar displaying the user's profile picture fetched from network
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(height: 24),
          
          // --------------------------------------------------------------------
          // USER IDENTITY (USERNAME)
          // --------------------------------------------------------------------
          Text(
            username,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          // --------------------------------------------------------------------
          // USER CONTACT (EMAIL)
          // --------------------------------------------------------------------
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
          Text(
            'SteamID: $steamId',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          
          // Added generous spacing before the main interaction buttons
          const SizedBox(height: 48),

          // --------------------------------------------------------------------
          // PRIMARY ACTION: ADD GAMES
          // --------------------------------------------------------------------
          // Enforce full width for the button with a specific height
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the nested "add_games" route using go_router.
                // This preserves the bottom navigation bar wrapper!
                context.go('/profile/add_games');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66c0f4), // Signature Steam blue
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
          
          // --------------------------------------------------------------------
          // LAYOUT HELPER
          // --------------------------------------------------------------------
          // The Spacer fluidly expands to consume all available vertical space, 
          // effectively pushing the logout button tightly against the bottom edge.
          const Spacer(),

          // --------------------------------------------------------------------
          // DANGEROUS/SECONDARY ACTION: LOG OUT
          // --------------------------------------------------------------------
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                final authService = context.read<AuthService>();
                await authService.logout();
                // We do not need to call context.go('/sign-in') here because 
                // in main.dart, GoRouter has `refreshListenable: authService`,
                // meaning it will automatically run its `redirect` logic and 
                // kick the user to '/sign-in' as soon as logout() calls notifyListeners().
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
          
          // Safety margin beneath the bottom button
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
