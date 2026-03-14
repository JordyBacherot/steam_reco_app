import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Button to navigate to the "Add Games" page
class AddGamesButton extends StatelessWidget {
  const AddGamesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => context.go('/profile/add_games'),
        child: const Text('Ajouter des jeux'),
      ),
    );
  }
}