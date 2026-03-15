import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/features/profile/widgets/steam_id_dialog.dart';

/// Header section of the profile page displaying user identity.
class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String steamId;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    required this.steamId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('assets/images/default_avatar.jpg'),
        ),
        const SizedBox(height: 24),
        Text(
          username,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.greyText,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'SteamID: $steamId',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.greyText.withOpacity(0.7),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () => SteamIdDialog.show(context, steamId),
              icon: const Icon(Icons.edit, size: 16),
              label: Text(
                steamId == 'Non lié' || steamId.isEmpty ? 'Ajouter' : 'Modifier',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}