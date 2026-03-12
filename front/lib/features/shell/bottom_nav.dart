import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';

class NavigationWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationWrapper({
    super.key,
    required this.navigationShell,
  });

  // Cette fonction est appelée automatiquement quand on clique sur un onglet.
  void _onItemTapped(BuildContext context, int index) {
    // Intercept the tap on the 'Deconnexion' icon (index 4)
    // to perform a logout action instead of navigating.
    if (index == 4) {
      // Execute the logout and GoRouter will redirect automatically
      context.read<AuthService>().logout();
      return;
    }

    // Si on tape sur l'onglet déjà actif ET qu'il y a des pages empilées,
    // on remonte d'un niveau (retour arrière) au lieu de réinitialiser la branche.
    if (index == navigationShell.currentIndex && context.canPop()) {
      context.pop();
      return;
    }

    // Use branch navigation for tabs 0 to 3
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold est le squelette visuel de base d'une page (ou de l'app entière).
    return Scaffold(
      backgroundColor: const Color(0xFF1b2838),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF171a21),
        selectedItemColor: const Color(0xFF66c0f4),
        unselectedItemColor: Colors.grey,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), label: 'Découvrir'),
          // L'icône de l'onglet Chatbot
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
