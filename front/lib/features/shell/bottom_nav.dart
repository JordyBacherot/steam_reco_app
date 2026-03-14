import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/core/theme/app_theme.dart';

/// A shell widget that wraps the main application pages with a persistent 
/// bottom navigation bar.
class NavigationWrapper extends StatelessWidget {
  /// The navigation shell provided by GoRouter to manage branch navigation.
  final StatefulNavigationShell navigationShell;

  const NavigationWrapper({
    super.key,
    required this.navigationShell,
  });

  // Cette fonction est appelée automatiquement quand on clique sur un onglet.
  void _onItemTapped(BuildContext context, int index) {
    if (index == 4) {
      Provider.of<AuthService>(context, listen: false).logout();
      return;
    }

    if (index == navigationShell.currentIndex && context.canPop()) {
      context.pop();
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.darkerBlue,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.greyText,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), label: 'Découvrir'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.logout), label: 'Deconnexion'),
        ],
      ),
    );
  }
}
