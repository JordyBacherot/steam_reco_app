// File: front/features/profile/widgets/profile_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/features/profile/widgets/profile_header.dart';
import 'package:front/features/profile/widgets/add_games_button.dart';
import 'package:front/features/profile/widgets/user_game_library.dart';
import 'package:front/features/profile/widgets/logout_button.dart';

/// Main profile page showing user info, game library, and logout option.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Header with avatar, username, email, and SteamID
          if (currentUser != null)
            ProfileHeader(
              username: currentUser.username,
              email: currentUser.email,
              steamId: currentUser.steamId ?? 'Non lié',
              avatarUrl: currentUser.profilePicture ??
                  'https://picsum.photos/id/237/200/300',
            ),

          const SizedBox(height: 8),

          /// Button to navigate to the "Add Games" page
          AddGamesButton(),

          const SizedBox(height: 16),

          /// User's game library
          if (currentUser != null)
            Expanded(
              child: UserGameLibrary(userId: currentUser.id),
            )
          else
            const Spacer(),

          const SizedBox(height: 32),

          /// Logout button
          const LogoutButton(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}