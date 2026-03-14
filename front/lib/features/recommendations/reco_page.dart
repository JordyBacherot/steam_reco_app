import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/core/network/api_client.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/recommendations/trend_map_modal.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/shared/widgets/status_views.dart';

/// The hub for choosing between different types of game recommendation methods.
class RecoPage extends StatefulWidget {
  const RecoPage({super.key});

  @override
  State<RecoPage> createState() => _RecoPageState();
}

/// State for [RecoPage] managing the display of recommendation options.
class _RecoPageState extends State<RecoPage> {

  /// Builds a clickable card for a recommendation type
  Widget _buildRecoCard({
    required BuildContext context,
    required String title,
    required String description,
    IconData? icon,
    String? imageAsset,
    required bool isEnabled,
    required String disabledReason,
    required VoidCallback onPressed,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Card(
        color: AppTheme.darkerBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isEnabled ? AppTheme.primaryBlue : Colors.grey[800]!,
            width: isEnabled ? 2 : 1,
          ),
        ),
        elevation: isEnabled ? 8 : 0,
        child: GestureDetector(
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (imageAsset != null)
                      if (imageAsset.endsWith('.svg'))
                        SvgPicture.asset(
                          imageAsset,
                          width: 40,
                          height: 40,
                          colorFilter: ColorFilter.mode(
                            isEnabled
                                ? AppTheme.primaryBlue
                                : Colors.grey[500]!,
                            BlendMode.srcIn,
                          ),
                        )
                      else
                        Image.asset(
                          imageAsset,
                          width: 40,
                          height: 40,
                          color: isEnabled
                              ? AppTheme.primaryBlue
                              : Colors.grey[500],
                        )
                    else if (icon != null)
                      Icon(
                        icon,
                        size: 40,
                        color: isEnabled
                            ? AppTheme.primaryBlue
                            : Colors.grey[500],
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    if (!isEnabled)
                      const Icon(Icons.lock, color: Colors.grey, size: 28),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.greyText,
                      ),
                ),
                if (!isEnabled) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            disabledReason,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ] else ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Découvrir',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                            color: AppTheme.primaryBlue, size: 18),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    final String steamId = currentUser?.steamId ?? '';
    final bool hasSteamId = steamId.isNotEmpty;

    final int addedGamesCount = authService.addedGamesCount;
    final bool hasEnoughGames = addedGamesCount >= 3;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Recommandations'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Trouver de nouveaux jeux',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez sur quelle base notre système doit vous recommander de nouveaux jeux.',
            style: const TextStyle(color: AppTheme.greyText, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Option 1: Steam Profile
          _buildRecoCard(
            context: context,
            title: 'Basé sur votre compte Steam',
            description:
                'Utilise la totalité des jeux présents sur votre compte Steam lié pour générer des recommandations ultra-précises.',
            imageAsset: 'assets/svg/steam_icon.svg',
            isEnabled: hasSteamId,
            disabledReason:
                'Nécessite de lier votre compte Steam dans votre profil.',
            onPressed: () {
              context.go('/reco/show?type=steam');
            },
          ),
          const SizedBox(height: 24),

          // Option 2: Custom Local Profile
          _buildRecoCard(
            context: context,
            title: 'Basé sur votre liste personnalisée',
            description:
                'Utilise les jeux que vous avez manuellement ajoutés dans votre bibliothèque sur l\'application.',
            icon: Icons.list_alt_rounded,
            isEnabled: hasEnoughGames,
            disabledReason:
                'Nécessite d\'ajouter au moins 3 jeux manuellement.\nActuel: $addedGamesCount/3',
            onPressed: () {
              context.go('/reco/show?type=manual');
            },
          ),
          const SizedBox(height: 24),

          // Option 3: trend dans le monde
          _buildRecoCard(
            context: context,
            title: 'Trend dans le monde',
            description:
                'Découvrez les jeux les plus populaires et tendances du moment à travers le monde.',
            icon: Icons.public,
            isEnabled: true,
            disabledReason: '',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const TrendMapModal(),
              );
            },
          ),
        ],
      ),
    );
  }
}
