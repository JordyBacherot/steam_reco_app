import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/recommendations/trend_map_modal.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/features/recommendations/widgets/reco_card.dart';
import 'package:front/shared/widgets/steam_logo.dart';

/// The hub for choosing between different types of game recommendation methods.
class RecoPage extends StatefulWidget {
  const RecoPage({super.key});

  @override
  State<RecoPage> createState() => _RecoPageState();
}

/// State for [RecoPage] managing the display of recommendation options.
class _RecoPageState extends State<RecoPage> {
  @override
  Widget build(BuildContext context) {
    // Access the current user and app state via AuthService
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    // Check if the user has linked a Steam account
    final String steamId = currentUser?.steamId ?? '';
    final bool hasSteamId = steamId.isNotEmpty;

    // Check if the user has enough games in their custom library
    final int addedGamesCount = authService.addedGamesCount;
    final bool hasEnoughGames = addedGamesCount >= 3;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Avoid bottom inset issues
      appBar: AppBar(
        title: const Text('Recommandations'),
        automaticallyImplyLeading: false, // Remove default back button
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Main page title
          Text(
            'Trouver de nouveaux jeux',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),

          // Subtitle / explanatory text
          const Text(
            'Choisissez sur quelle base notre système doit vous recommander de nouveaux jeux.',
            style: TextStyle(color: AppTheme.greyText, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // --- Option 1: Steam Profile ---
          RecoCard(
            title: 'Basé sur votre compte Steam',
            description: 'Utilise la totalité des jeux présents sur votre compte Steam lié pour générer des recommandations ultra-précises.',
            isEnabled: hasSteamId, // Enabled only if Steam is linked
            disabledReason: 'Vous devez lier votre compte Steam pour utiliser cette fonctionnalité.',
            onPressed: () => context.go('/reco/show?type=steam'), // Navigate to Steam recommendations
            leading: SteamLogo(
              size: 40,
              color: hasSteamId ? AppTheme.primaryBlue : Colors.grey[500]!,
            ),
          ),
          const SizedBox(height: 24),

          // --- Option 2: Custom Local Profile ---
          RecoCard(
            title: 'Basé sur votre liste personnalisée',
            description: 'Utilise les jeux que vous avez manuellement ajoutés dans votre bibliothèque sur l\'application.',
            isEnabled: hasEnoughGames, // Enabled if user has ≥3 games
            disabledReason: 'Vous devez ajouter au moins 3 jeux à votre liste personnalisée pour utiliser cette fonctionnalité.',
            onPressed: () => context.go('/reco/show?type=manual'), // Navigate to manual recommendations
            leading: Icon(
              Icons.list_alt_rounded,
              size: 40,
              color: hasEnoughGames ? AppTheme.primaryBlue : Colors.grey[500]!,
            ),
          ),
          const SizedBox(height: 24),

          // --- Option 3: Trend dans le monde ---
          RecoCard(
            title: 'Trend dans le monde',
            description:
                'Découvrez les jeux les plus populaires et tendances du moment à travers le monde.',
            isEnabled: true, // Always enabled
            disabledReason: '', // No disabled reason
            onPressed: () {
              // Show a modal with a world trend map
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => const TrendMapModal(),
              );
            },
            leading: Icon(
              Icons.public,
              size: 40,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}