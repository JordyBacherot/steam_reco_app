import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/shared/widgets/game_card.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:front/shared/widgets/empty_state.dart';
import 'package:front/models/recommendation_model.dart';

/// Displays the list of past recommendation sessions.
/// Shows an empty state with a CTA if there are no sessions yet.
class RecommendationList extends StatelessWidget {
  final List<RecommendationModel> recommendations;

  const RecommendationList({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Dernières recommandations :'),
        if (recommendations.isEmpty)
          EmptyState(
            message: "Aucune recommandation pour l'instant",
            buttonLabel: 'Commencer maintenant !',
            onButtonPressed: () => context.go('/reco'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reco = recommendations[index];
              final firstGame = reco.games.isNotEmpty ? reco.games.first : null;
              return GameCard(
                name: "Recommandation ${reco.type}",
                description: "Session du ${reco.createdAt.day}/${reco.createdAt.month} à ${reco.createdAt.hour}h${reco.createdAt.minute}",
                imageUrl: firstGame?.imageUrl,
                onTap: () => context.go('/reco'),
              );
            },
          ),
      ],
    );
  }
}
