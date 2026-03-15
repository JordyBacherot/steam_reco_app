import 'package:flutter/material.dart';
import 'package:front/shared/widgets/steam_logo.dart';

/// Displays the Steam logo and app title "Reco Steam" side by side.
/// Use anywhere a consistent app branding header is needed.
class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SteamLogo(size: 40, color: Colors.white),
        const SizedBox(width: 12),
        Text(
          'Reco Steam',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
        ),
      ],
    );
  }
}