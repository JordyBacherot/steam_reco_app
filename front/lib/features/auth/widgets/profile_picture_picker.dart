import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicturePicker extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;
  final double radius;

  const ProfilePicturePicker({
    super.key,
    this.imageUrl,
    required this.onTap,
    this.radius = 50,
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
              radius: radius,
              backgroundColor: Colors.white.withOpacity(0.1),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null
                  ? Icon(Icons.person, size: radius * 1.2, color: AppTheme.greyText)
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}