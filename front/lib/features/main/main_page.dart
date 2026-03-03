import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/features/main/widgets/profile_card.dart';
import 'package:front/features/main/widgets/recommendation_list.dart';
import 'package:front/models/game_model.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the current user from AuthService
    final authService = context.watch<AuthService>();
    final currentUser = authService.currentUser;

    // Fake game data moved from RecommendationList
    final List<GameModel> fakeGames = [
      const GameModel(
        id: '1091500',
        title: 'Cyberpunk 2077',
        imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1091500/capsule_231x87.jpg',
      ),
      const GameModel(
        id: '367520',
        title: 'Hollow Knight',
        imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/367520/capsule_231x87.jpg',
      ),
      const GameModel(
        id: '413150',
        title: 'Stardew Valley',
        imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/413150/capsule_231x87.jpg',
      ),
      const GameModel(
        id: '1245620',
        title: 'Elden Ring',
        imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1245620/capsule_231x87.jpg',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // First element: Logged in User Information Card
        ProfileCard(
          avatarUrl: currentUser?['profile_picture'] ?? 'https://picsum.photos/id/237/200/300',
          username: currentUser?['username'] ?? 'User',
          level: currentUser?['level'] ?? 1,
          lastConnection: 'Connected', 
        ),
        const SizedBox(height: 24),
        
        // Second element: Recommendations List
        RecommendationList(games: fakeGames),
      ],
    );
  }
}
