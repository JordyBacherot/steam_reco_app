import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/features/shell/bottom_nav.dart';
import 'package:front/features/main/main_page.dart';
import 'package:front/features/recommendations/reco_page.dart';
import 'package:front/features/recommendations/reco_show_page.dart';
import 'package:front/features/chatbot/chatbot_page.dart';
import 'package:front/features/profile/profile_page.dart';
import 'package:front/features/profile/add_games_page.dart';
import 'package:front/features/auth/sign_in_page.dart';
import 'package:front/features/auth/sign_up_page.dart';
import 'package:front/features/games/widgets/game_pages.dart';
import 'package:front/services/auth_service.dart';

/// Centralized navigation configuration for the application using [GoRouter].
///
/// This class defines the application's routing structure, including
/// authentication-based redirection logic and nested navigation shells.
class AppRouter {
  /// Configures and returns a [GoRouter] instance.
  ///
  /// [authService] provides the reactive authentication state used for 
  /// guard-based redirection.
  static GoRouter createRouter(AuthService authService) {
    return GoRouter(
      // Monitor AuthService to re-evaluate routes when login state changes.
      refreshListenable: authService,

      // Initial route depends on current authentication status.
      initialLocation: authService.isAuthenticated ? '/' : '/sign-in',

      /// Global redirection guard.
      ///
      /// Protects all routes except sign-in/sign-up from unauthenticated access.
      /// Also redirects logged-in users away from authentication pages.
      redirect: (context, state) {
        final isLoggedIn = authService.isAuthenticated;
        final isGoingToAuth = state.uri.path == '/sign-in' || state.uri.path == '/sign-up';

        // Do not redirect while the session status is still being determined.
        if (authService.isLoading) return null;

        // Force sign-in if accessing protected routes while logged out.
        if (!isLoggedIn && !isGoingToAuth) {
          return '/sign-in';
        }

        // Redirect to home if accessing auth pages while already logged in.
        if (isLoggedIn && isGoingToAuth) {
          return '/';
        }

        return null;
      },
      routes: [
        // Public Authentication Routes
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpPage(),
        ),

        /// Primary application structure with persistent bottom navigation.
        ///
        /// Uses [StatefulShellRoute] to maintain page state across tabs.
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return NavigationWrapper(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: Home / Library
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

            // Branch 1: Discover / Recommendations
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/reco',
                  builder: (context, state) => const RecoPage(),
                  routes: [
                    GoRoute(
                      path: 'show',
                      builder: (context, state) {
                        final type = state.uri.queryParameters['type'] ?? 'steam';
                        return RecoShowPage(type: type);
                      },
                    ),
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

            // Branch 2: AI Chatbot
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/chatbot',
                  builder: (context, state) => const ChatbotPage(),
                ),
              ],
            ),

            // Branch 3: User Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfilePage(),
                  routes: [
                    GoRoute(
                      path: 'add_games',
                      builder: (context, state) => const AddGamesPage(),
                    ),
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

            // Branch 4: Logout (Placeholder for trigger)
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
}
