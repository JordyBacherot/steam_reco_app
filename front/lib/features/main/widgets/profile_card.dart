import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileCard extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final int level;
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
      color: const Color(0xFF2A475E), // Match the dark blue-grey from RecommendationList
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
                        color: Colors.grey[300], // Lighter grey for better contrast
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last connexion: $lastConnection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400], // Lighter grey for better contrast
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
