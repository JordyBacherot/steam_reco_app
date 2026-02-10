import 'package:flutter/material.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Accueil', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Recommandations', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Chatbot', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Profil', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Deconnexion', style: TextStyle(color: Colors.white)))
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1b2838), 
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF171a21), 
        selectedItemColor: const Color(0xFF66c0f4),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
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