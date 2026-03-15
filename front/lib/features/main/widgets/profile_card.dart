import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/theme/app_theme.dart';

/// A card widget that displays a concise summary of the user's profile.
class ProfileCard extends StatelessWidget {
  final String username;
  final int level;
  final String lastConnection;

  const ProfileCard({
    super.key,
    required this.username,
    required this.level,
    required this.lastConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/profile'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundImage: AssetImage('assets/images/default_avatar.jpg'),
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
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Niveau $level',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightGreyText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dernière connexion: $lastConnection',
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