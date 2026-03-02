import 'package:flutter/material.dart';
import 'package:front/features/chatbot/chatbot_page.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  // Garde en mémoire l'index de l'onglet actuellement sélectionné.
  // "0" correspond au premier onglet (Accueil).
  int _selectedIndex = 0;

  // Liste des vues (Pages) correspondant à chaque onglet de la barre de navigation.
  final List<Widget> _pages = [
    const Center(child: Text('Accueil', style: TextStyle(color: Colors.white))),
    const Center(
        child: Text('Recommandations', style: TextStyle(color: Colors.white))),
    const ChatbotPage(),
    const Center(child: Text('Profil', style: TextStyle(color: Colors.white))),
    const Center(
        child: Text('Deconnexion', style: TextStyle(color: Colors.white)))
  ];

  // Cette fonction est appelée automatiquement quand on clique sur un onglet.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold est le squelette visuel de base d'une page (ou de l'app entière).
    return Scaffold(
      backgroundColor: const Color(0xFF1b2838), // Couleur de fond style Steam
      // Affiche la page correspondant à l'index sélectionné parmi _pages.
      body: _pages[_selectedIndex],
      // La barre de navigation en bas de l'écran.
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF171a21),
        selectedItemColor: const Color(0xFF66c0f4),
        unselectedItemColor: Colors.grey,
        currentIndex:
            _selectedIndex, // Indique visuellement quel bouton est actif
        onTap: _onItemTapped, // Ce qu'il se passe au clic -> change l'index
        type: BottomNavigationBarType
            .fixed, // Permet d'avoir plus de 3 onglets sans animations bizarres
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), label: 'Découvrir'),
          // L'icône de l'onglet Chatbot (il correspond à l'index 2 de _pages)
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
