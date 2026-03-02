import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The [ProfilePage] displays the current user's profile information, including
/// their avatar, username, email, and SteamID. It also provides primary actions 
/// to add new games to their collection or log out of the application.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------------------------------
    // STATIC MOCK DATA
    // --------------------------------------------------------------------------
    // TODO: Replace these static variables with a real User model injected 
    // via a state management solution (e.g. Provider, Riverpod, or BLoC).
    const String username = 'JordyBacherot';
    const String email = 'jordy.bacherot@example.com';
    const String steamId = 'STEAM_0:1:12345678';
    const String avatarUrl = 'https://picsum.photos/id/237/200/300';

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
          const CircleAvatar(
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
              onPressed: () {
                // TODO: Clear local authentication tokens and route back to login screen
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
