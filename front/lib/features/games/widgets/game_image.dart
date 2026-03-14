import 'package:flutter/material.dart';

class GameHeroImage extends StatelessWidget {
  final String imageUrl;

  const GameHeroImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 250,
        color: const Color(0xFF171a21),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
        ),
      ),
    );
  }
}