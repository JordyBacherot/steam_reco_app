import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/features/main/widgets/profile_card.dart';
import 'package:front/features/main/widgets/recommendation_list.dart';
import 'package:front/services/chatbot_service.dart';
import 'package:front/services/recommendation_service.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/shared/widgets/app_title.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final RecommendationService _recoService;

  @override
  void initState() {
    super.initState();
    _recoService = context.read<RecommendationService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recoService.fetchAiHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthService>().currentUser;
    final chatbotService = context.read<ChatbotService>();

    return Scaffold(
      backgroundColor: AppTheme.darkBlue,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App title
          const SizedBox(height: 12),
          const AppTitle(),
          const SizedBox(height: 24),

          // 1. User Profile Header
          ProfileCard(
            username: currentUser?.username ?? 'User',
            level: currentUser?.level ?? 1,
            lastConnection: 'Connecté',
          ),

          const SizedBox(height: 24),

          // 2. AI Recommendation History
          Consumer<RecommendationService>(
            builder: (context, recoService, _) {
              final displayed_recommendations = recoService.recommendations.length > 3
                  ? recoService.recommendations.sublist(0, 3)
                  : recoService.recommendations;
              if (recoService.isLoadingHistory) {
                return const Center(child: CircularProgressIndicator());
              }
              return RecommendationList(
                recommendations: displayed_recommendations,
              );
            },
          ),

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
                tileColor: AppTheme.cardGrey,
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
      isScrollControlled: true,
      backgroundColor: AppTheme.cardGrey,
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