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

/// Point d'entrée de l'application Flutter.
/// Initialise Flutter, charge les variables d'environnement (.env), crée le service d'authentification et démarre l'application.
Future<void> main() async {
  // Nécessaire pour utiliser des plugins natifs avant runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Chargement du fichier .env (ex: API_URL)
  await dotenv.load(fileName: ".env");

  // Initialisation de l'AuthService : restaure la session si un token est stocké localement
  final authService = AuthService();
  await authService.init();

  // Injection de l'AuthService dans l'arbre de widgets via Provider
  runApp(
    ChangeNotifierProvider.value(
      value: authService,
      child: MainApp(authService: authService),
    ),
  );
}

/// Crée et configure le routeur GoRouter de l'application.
/// Le routeur gère :
///   - La redirection selon l'état d'authentification
///   - Les routes publiques (sign-in, sign-up)
///   - Les routes protégées avec barre de navigation (StatefulShellRoute)
GoRouter _createRouter(AuthService authService) {
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
      // StatefulShellRoute.indexedStack maintient l'état de chaque onglet
      // (la page n'est pas reconstruite quand on change d'onglet).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // NavigationWrapper construit le Scaffold avec la BottomNavigationBar
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
                  // Sous-route : détail d'un jeu depuis l'accueil → /game/:id
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

          // Onglet 1 : Découvrir (Recommandations) ---
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reco',
                builder: (context, state) => const RecoPage(),
                routes: [
                  // Sous-route : affichage des recommandations → /reco/show?type=steam|manual
                  GoRoute(
                    path: 'show',
                    builder: (context, state) {
                      final type = state.uri.queryParameters['type'] ?? 'steam';
                      return RecoShowPage(type: type);
                    },
                  ),
                  // Sous-route : détail d'un jeu depuis les recommandations → /reco/game/:id
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
                  // Sous-route : ajout de jeux à la bibliothèque → /profile/add_games
                  GoRoute(
                    path: 'add_games',
                    builder: (context, state) => const AddGamesPage(),
                  ),
                  // Sous-route : détail d'un jeu depuis le profil → /profile/game/:id
                  // Nécessaire pour garder le contexte du profil (barre de navigation préservée)
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

          // Onglet 4 : Déconnexion (géré via NavigationWrapper)
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

/// Widget racine de l'application.
/// Affiche un écran de chargement pendant l'initialisation de l'AuthService, puis lance l'application avec le routeur configuré et le thème sombre Steam.
class MainApp extends StatelessWidget {
  final AuthService authService;

  const MainApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    // Affichage d'un indicateur de chargement pendant la vérification du token stocké
    if (authService.isLoading) {
      return const MaterialApp(
         home: Scaffold(
            backgroundColor: Color(0xFF1b2838),
            body: Center(child: CircularProgressIndicator()),
         )
      );
    }

    return MaterialApp.router(
      // Connexion du routeur GoRouter à MaterialApp
      routerConfig: _createRouter(authService),
      // Thème sombre avec la couleur de fond Steam
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1b2838),
      ),
    );
  }
}
