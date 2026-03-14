import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/features/main/widgets/profile_card.dart';
import 'package:front/features/main/widgets/recommendation_list.dart';
import 'package:front/models/recommendation_model.dart';
import 'package:front/models/game_model.dart';

/// The primary landing page of the application after authentication.
///
/// Displays a quick overview of the user profile and their most recent 
/// recommendation sessions.
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthService>().currentUser;

    // Fake recommendation session — replace with real data when history endpoint is available
    final fakeRecommendations = [
      RecommendationModel(
        type: 'IA',
        createdAt: DateTime(2026, 3, 12, 10, 30),
        games: const [
          GameModel(
            id: '1091500',
            title: 'Cyberpunk 2077',
            imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1091500/capsule_231x87.jpg',
          ),
          GameModel(
            id: '367520',
            title: 'Hollow Knight',
            imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/367520/capsule_231x87.jpg',
          ),
          GameModel(
            id: '413150',
            title: 'Stardew Valley',
            imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/413150/capsule_231x87.jpg',
          ),
        ],
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ProfileCard(
          avatarUrl: currentUser?.profilePicture ?? 'https://picsum.photos/id/237/200/300',
          username: currentUser?.username ?? 'User',
          level: currentUser?.level ?? 1,
          lastConnection: 'Connected',
        ),
        const SizedBox(height: 24),
        RecommendationList(recommendations: fakeRecommendations),
      ],
    );
  }
}
