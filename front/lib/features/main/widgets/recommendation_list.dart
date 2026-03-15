import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/shared/widgets/section_title.dart';
import 'package:front/shared/widgets/empty_state.dart';
import 'package:front/models/recommendation_model.dart';
import 'package:front/features/main/widgets/recommendation_card.dart';

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
        const SectionTitle(title: 'Recommandations récentes :'),
        if (recommendations.isEmpty)
          EmptyState(
            message: "Aucune recommandation pour le moment.",
            buttonLabel: 'Commencer!',
            onButtonPressed: () => context.go('/reco'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return RecommendationCard(
                recommendation: recommendations[index],
                onTap: () => context.go('/reco'),
              );
            },
          ),
      ],
    );
  }
}