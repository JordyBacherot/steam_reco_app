import 'package:flutter/material.dart';
import 'package:front/shared/widgets/game_card.dart';

/// A reusable widget to display a list of games using [GameCard].
class GameList extends StatelessWidget {
  /// The list of items to display.
  final List<dynamic> games;

  /// A function to build a [GameCard] from a game item.
  final GameCard Function(BuildContext context, dynamic game) cardBuilder;

  /// Optional message to show when the list is empty.
  final String? emptyMessage;

  /// Spacing between items.
  final double spacing;

  /// Whether the list should wrap its content.
  final bool shrinkWrap;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  const GameList({
    super.key,
    required this.games,
    required this.cardBuilder,
    this.emptyMessage,
    this.spacing = 12,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            emptyMessage ?? 'Aucun jeu trouvé.',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: games.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) => cardBuilder(context, games[index]),
    );
  }
}
