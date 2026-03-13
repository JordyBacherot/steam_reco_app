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
import 'package:front/features/games/game_pages.dart';
import 'package:front/services/auth_service.dart';

class AppRouter {
  /// Crée et configure le routeur GoRouter de l'application.
  static GoRouter createRouter(AuthService authService) {
    return GoRouter(
      // GoRouter écoute les changements de l'AuthService pour recalculer les redirections
      refreshListenable: authService,
      // Page initiale selon que l'utilisateur est déjà connecté ou non
      initialLocation: authService.isAuthenticated ? '/' : '/sign-in',

      redirect: (context, state) {
        // Access auth state
        final isLoggedIn = authService.isAuthenticated;
        
        // Determine if we are on an auth-related page
        final isGoingToAuth = state.uri.path == '/sign-in' || state.uri.path == '/sign-up';

        // While checking the token, don't redirect
        if (authService.isLoading) return null;

        // If NOT logged in and trying to access a protected page -> FORCE login
        if (!isLoggedIn && !isGoingToAuth) {
          return '/sign-in';
        }

        // If ALREADY logged in and trying to access login/register -> Home
        if (isLoggedIn && isGoingToAuth) {
          return '/';
        }

        // Pas de redirection nécessaire
        return null;
      },
      routes: [
        // Route de connexion (accessible sans authentification)
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInPage(),
        ),
        // Route d'inscription (accessible sans authentification)
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpPage(),
        ),

        // Routes protégées avec barre de navigation inférieure.
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return NavigationWrapper(navigationShell: navigationShell);
          },
          branches: [
            // Onglet 0 : Accueil
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

            // Onglet 1 : Découvrir (Recommandations)
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

            // Onglet 2 : Chatbot
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/chatbot',
                  builder: (context, state) => const ChatbotPage(),
                ),
              ],
            ),

            // Onglet 3 : Profil
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

            // Onglet 4 : Déconnexion
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
