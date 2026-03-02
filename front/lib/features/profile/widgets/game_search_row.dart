import 'package:flutter/material.dart';
import 'package:front/features/main/models/game_model.dart';

class GameSearchRow extends StatelessWidget {
  final List<GameModel> availableGames;
  final GameModel? selectedGame;
  final ValueChanged<GameModel?> onGameSelected;
  final TextEditingController ratingController;

  const GameSearchRow({
    super.key,
    required this.availableGames,
    required this.selectedGame,
    required this.onGameSelected,
    required this.ratingController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dropdown
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<GameModel>(
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2A475E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: 'Rechercher un jeu...',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            dropdownColor: const Color(0xFF2A475E),
            value: selectedGame,
            items: availableGames.map((game) {
              return DropdownMenuItem<GameModel>(
                value: game,
                child: Text(
                  game.title,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onGameSelected,
          ),
        ),
        const SizedBox(width: 16),
        
        // Rating Input
        Expanded(
          flex: 1,
          child: Row(
            children: [
              const Text(
                'Note: ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Expanded(
                child: TextField(
                  controller: ratingController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2A475E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                ),
              ),
              const Text(
                ' /5',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
