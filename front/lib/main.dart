import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/shell/bottom_nav.dart';
import 'package:front/features/main/main_page.dart';
import 'package:front/features/recommendations/reco_page.dart';
import 'package:front/features/chatbot/chatbot_page.dart';
import 'package:front/features/profile/profile_page.dart';
import 'package:front/features/profile/add_games_page.dart';

void main() {
  runApp(const MainApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // Return the NavigationWrapper which builds the Scaffold and BottomNavigationBar
        return NavigationWrapper(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Accueil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => MainPage(),
            ),
          ],
        ),
        // Tab 1: Découvrir
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reco',
              builder: (context, state) => const RecoPage(),
            ),
          ],
        ),
        // Tab 2: Chatbot
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chatbot',
              builder: (context, state) => const ChatbotPage(),
            ),
          ],
        ),
        // Tab 3: Profil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'add_games', // Sub-route of profile
                  builder: (context, state) => const AddGamesPage(),
                ),
              ],
            ),
          ],
        ),
        // Tab 4 (Déconnexion) is handled natively by the onTap intercept inside NavigationWrapper
        // so we just define a dummy branch to match the 5 BottomNavigationBar items needed.
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/logout_action',
              builder: (context, state) => const SizedBox(), 
            ),
          ],
        ),
      ],
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1b2838),
      ),
    );
  }
}
