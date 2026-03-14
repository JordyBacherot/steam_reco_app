import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/theme/app_theme.dart';

/// A card widget that displays a concise summary of the user's profile.
///
/// Shows the user's avatar, username, level, and last connection status.
/// Tapping the card navigates directly to the full profile page.
class ProfileCard extends StatelessWidget {
  /// The URL for the user's profile avatar.
  final String avatarUrl;
  
  /// The user's display name.
  final String username;
  
  /// The user's current progress level.
  final int level;
  
  /// A string indicating when the user was last active.
  final String lastConnection;

  const ProfileCard({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.level,
    required this.lastConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppTheme.cardGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to the profile page when tapped
          context.go('/profile'); 
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Make text white
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level $level',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightGreyText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last connexion: $lastConnection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
