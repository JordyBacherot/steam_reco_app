import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:front/services/auth_service.dart';
import 'package:front/services/game_service.dart';
import 'package:front/services/recommendation_service.dart';
import 'package:front/core/navigation/app_router.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/core/network/api_client.dart';
import 'package:front/core/network/secure_storage.dart';
import 'package:front/services/chatbot_service.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  await dotenv.load(fileName: ".env");

  // Central dependencies
  final apiClient = ApiClient();
  final secureStorage = SecureStorage();

  // Initialize authentication service
  final authService = AuthService(apiClient, secureStorage);
  await authService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<SecureStorage>.value(value: secureStorage),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<GameService>(
          create: (context) => GameService(apiClient),
        ),
        Provider<RecommendationService>(
          create: (context) => RecommendationService(apiClient)),
        Provider<ChatbotService>(create: (context) => ChatbotService(apiClient)),
      ],
    child: const MainApp(),
  ),
);
}

/// Root widget of the application.
///
/// Responsible for:
/// - reacting to AuthService state
/// - displaying a boot/loading screen during initialization
/// - creating the router once authentication is ready
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // While AuthService initializes (token restore, API check, etc.)
    // we display a minimal boot screen to avoid router initialization
    if (authService.isLoading) {
      return const _BootApp();
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // Router configuration depends on authentication state
      routerConfig: AppRouter.createRouter(authService),

      // Builder used to sanitize MediaQuery insets.
      // Flutter Web can sometimes report negative viewInsets during
      // browser resize or soft-keyboard appearance, which can trigger
      // `_viewInsets.isNonNegative` assertions.
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        final data = MediaQuery.of(context);

        return MediaQuery(
          data: data.copyWith(
            viewInsets: data.viewInsets.copyWith(
              top: math.max(0.0, data.viewInsets.top),
              bottom: math.max(0.0, data.viewInsets.bottom),
              left: math.max(0.0, data.viewInsets.left),
              right: math.max(0.0, data.viewInsets.right),
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// Minimal boot screen displayed during application startup.
///
/// We intentionally avoid using complex layout widgets here because
/// Flutter Web may trigger layout assertions during the very first frame
/// of the engine boot. A simple container-based screen is the safest.
class _BootApp extends StatelessWidget {
  const _BootApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Container(
        color: AppTheme.darkBlue,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }
}