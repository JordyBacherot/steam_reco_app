import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        Text(
          'Dernières recommandations :',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        if (recommendations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  const Text(
                    "Aucune recommandation pour l'instant",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/reco'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF66c0f4),
                    ),
                    child: const Text(
                      'Commencer maintenant !',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
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
