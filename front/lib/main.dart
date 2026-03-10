import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/shell/bottom_nav.dart';
import 'package:front/features/main/main_page.dart';
import 'package:front/features/recommendations/reco_page.dart';
import 'package:front/features/recommendations/reco_show_page.dart';
import 'package:front/features/chatbot/chatbot_page.dart';
import 'package:front/features/profile/profile_page.dart';
import 'package:front/features/profile/add_games_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:front/features/auth/sign_in_page.dart';
import 'package:front/features/auth/sign_up_page.dart';
import 'package:front/features/games/game_pages.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final authService = AuthService();
  await authService.init();

  runApp(
    ChangeNotifierProvider.value(
      value: authService,
      child: MainApp(authService: authService),
    ),
  );
}

GoRouter _createRouter(AuthService authService) {
  return GoRouter(
    refreshListenable: authService,
    initialLocation: authService.isAuthenticated ? '/' : '/sign-in',
    redirect: (context, state) {
      final isLoggedIn = authService.isAuthenticated;
      final isGoingToAuth = state.matchedLocation == '/sign-in' || state.matchedLocation == '/sign-up';

      // If securely loading on app start, don't redirect yet
      if (authService.isLoading) return null;

      if (!isLoggedIn && !isGoingToAuth) {
        return '/sign-in'; // Redirect to login if not logged in
      }

      if (isLoggedIn && isGoingToAuth) {
        return '/'; // Redirect to home if already logged in and trying to access auth pages
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
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
                routes: [
                  GoRoute(
                    path: 'game/:id',
                    builder: (context, state) {
                      final gameId = state.pathParameters['id']!;
                      return GamePages(gameId: gameId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Tab 1: Découvrir
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reco',
                builder: (context, state) => const RecoPage(),
                routes: [
                  GoRoute(
                    path: 'show', // Sub-route becomes /reco/show
                    builder: (context, state) {
                      final type = state.uri.queryParameters['type'] ?? 'steam';
                      return RecoShowPage(type: type);
                    },
                  ),
                ],
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
}

class MainApp extends StatelessWidget {
  final AuthService authService;

  const MainApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    // Show a loading screen while auth completes (very quick usually)
    if (authService.isLoading) {
      return const MaterialApp(
         home: Scaffold(
            backgroundColor: Color(0xFF1b2838),
            body: Center(child: CircularProgressIndicator()),
         )
      );
    }

    return MaterialApp.router(
      routerConfig: _createRouter(authService),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1b2838),
      ),
    );
  }
}
