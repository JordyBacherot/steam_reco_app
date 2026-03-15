import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/features/main/widgets/profile_card.dart';
import 'package:front/features/main/widgets/recommendation_list.dart';
import 'package:front/models/recommendation_model.dart';
import 'package:front/models/game_model.dart';
import 'package:front/services/chatbot_service.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the user state for reactive updates
    final currentUser = context.watch<AuthService>().currentUser;
    // Access service without listening (best for one-off calls like fetchLastConversation)
    final chatbotService = Provider.of<ChatbotService>(context, listen: false);

    final fakeRecommendations = [
      RecommendationModel(
        type: 'IA',
        createdAt: DateTime(2026, 3, 12, 10, 30),
        games: const [
          GameModel(
            id: '1091500',
            title: 'Cyberpunk 2077',
            imageUrl:
                'https://cdn.akamai.steamstatic.com/steam/apps/1091500/capsule_231x87.jpg',
          ),
          GameModel(
            id: '367520',
            title: 'Hollow Knight',
            imageUrl:
                'https://cdn.akamai.steamstatic.com/steam/apps/367520/capsule_231x87.jpg',
          ),
          GameModel(
            id: '413150',
            title: 'Stardew Valley',
            imageUrl:
                'https://cdn.akamai.steamstatic.com/steam/apps/413150/capsule_231x87.jpg',
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor:
          const Color(0xFF1B2838), // Standard Steam-like background
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. User Profile Header
          ProfileCard(
            avatarUrl: currentUser?.profilePicture ??
                'https://picsum.photos/id/237/200/300',
            username: currentUser?.username ?? 'User',
            level: currentUser?.level ?? 1,
            lastConnection: 'Connected',
          ),

          const SizedBox(height: 24),

          // 2. Recommendations Section
          RecommendationList(recommendations: fakeRecommendations),

          const SizedBox(height: 24),

          // 3. Last Chat Preview
          FutureBuilder<Map<String, dynamic>?>(
            future: chatbotService.fetchLastConversation(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!['messages'].isEmpty) {
                return const SizedBox.shrink();
              }

              final messages = snapshot.data!['messages'] as List;
              final lastMsg = messages.last['content'] ?? '';

              return ListTile(
                tileColor: const Color(0xFF2A475E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                leading:
                    const Icon(Icons.chat_bubble, color: Colors.blueAccent),
                title: const Text("Dernier échange avec Chatbot",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.white24),
                onTap: () => _showChatHistoryModal(context, snapshot.data!),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showChatHistoryModal(
      BuildContext context, Map<String, dynamic> chatData) {
    final List messages = chatData['messages'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to take up more space if needed
      backgroundColor: const Color(0xFF1B2838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const Text(
              "Dernière discussion",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const Divider(color: Colors.white24),
            ...messages.map((m) {
              final isUser = m['role'] == 'user';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isUser ? "Vous" : "IA",
                  style: TextStyle(
                    color: isUser ? Colors.blueAccent : Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  m['content'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
