import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';

/// A customizable widget for selecting and displaying a profile picture.
class ProfilePicturePicker extends StatelessWidget {
  /// The URL of the currently selected profile image.
  final String? imageUrl;
  
  /// Callback triggered when the user taps to edit the picture.
  final VoidCallback onTap;

  const ProfilePicturePicker({
    super.key,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.1),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: AppTheme.greyText,
                    )
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
