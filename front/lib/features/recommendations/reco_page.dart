import 'package:flutter/material.dart';

class RecoPage extends StatelessWidget {
  const RecoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement recommendations fetch logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF66c0f4), // Steam blue
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Obtenir des recommandations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

