import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GamePages extends StatelessWidget {
  final String gameId;

  const GamePages({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          'Détails pour le jeu ID: $gameId\n(Page en cours de construction)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
