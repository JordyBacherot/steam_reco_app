import 'package:flutter/material.dart';
import 'package:front/models/game_model_detailed.dart';

class GameHeaderWidget extends StatelessWidget {
  final GameModelDetailed game;

  const GameHeaderWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          game.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (game.studio != null && game.studio!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            game.studio!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (game.meanReview != null) ...[
          const SizedBox(height: 8),
          Text(
            '${(game.meanReview! * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 16, 
              color: Colors.white70, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}