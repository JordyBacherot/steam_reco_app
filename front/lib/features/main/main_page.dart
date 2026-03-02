import 'package:flutter/material.dart';
import 'package:front/features/main/widgets/profile_card.dart';
import 'package:front/features/main/widgets/recommendation_list.dart';
import 'package:front/features/main/models/game_model.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fake game data moved from RecommendationList
    final List<GameModel> fakeGames = [
      const GameModel(
        title: 'Cyberpunk 2077',
        imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1091500/capsule_231x87.jpg',
      ),
      const GameModel(
        title: 'Hollow Knight',
        imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/367520/capsule_231x87.jpg',
      ),
      const GameModel(
        title: 'Stardew Valley',
        imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/413150/capsule_231x87.jpg',
      ),
      const GameModel(
        title: 'Elden Ring',
        imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1245620/capsule_231x87.jpg',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // First element: Logged in User Information Card
        const ProfileCard(
          avatarUrl: 'https://picsum.photos/id/237/200/300', // Fake profile picture
          username: 'JordyBacherot', // Fake username
          level: 42, // Fake level
          lastConnection: '2 hours ago', // Fake last connexion
        ),
        const SizedBox(height: 24),
        
        // Second element: Recommendations List
        RecommendationList(games: fakeGames),
      ],
    );
  }
}
