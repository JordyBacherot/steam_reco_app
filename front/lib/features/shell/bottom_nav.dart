import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationWrapper({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    // Intercept the tap on the 'Deconnexion' icon (index 4) 
    // to perform a logout action instead of navigating.
    if (index == 4) {
      // TODO: Implement the actual logout logic here (e.g. clear tokens, route to SignIn)
      debugPrint("Action: Déconnexion triggered");
      // Return early: we do NOT navigate
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
    return Scaffold(
      backgroundColor: const Color(0xFF1b2838), 
      // The child of the Scaffold is the "Current Tab" provided by the NavigationShell
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF171a21), 
        selectedItemColor: const Color(0xFF66c0f4),
        unselectedItemColor: Colors.grey,
        currentIndex: navigationShell.currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Découvrir'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Deconnexion'),
        ],
      ),
    );
  }
}