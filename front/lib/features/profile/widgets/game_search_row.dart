import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/models/game_model.dart';
import 'package:front/services/game_service.dart';
import 'package:front/core/theme/app_theme.dart';

/// A specialized row combining a game autocomplete search and an ivory hours picker.
class GameSearchRow extends StatefulWidget {
  /// List of games that can be suggested (currently empty for server-side search).
  final List<GameModel> availableGames;
  
  /// The currently selected game, if any.
  final GameModel? selectedGame;
  
  /// Callback triggered when a game is selected from the suggestions.
  final ValueChanged<GameModel?> onGameSelected;
  
  /// Controller managing the text input for hours.
  final TextEditingController hoursController;

  const GameSearchRow({
    super.key,
    required this.availableGames,
    required this.selectedGame,
    required this.onGameSelected,
    required this.hoursController,
  });

  @override
  State<GameSearchRow> createState() => _GameSearchRowState();
}

/// State for [GameSearchRow] managing the scroll controller for the hours wheel.
class _GameSearchRowState extends State<GameSearchRow> {
  late FixedExtentScrollController _scrollController;
  static const int _maxHours = 9999;

  @override
  void initState() {
    super.initState();
    final initial = int.tryParse(widget.hoursController.text) ?? 0;
    _scrollController = FixedExtentScrollController(initialItem: initial);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search field with label
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nom du jeu',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Autocomplete<GameModel>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<GameModel>.empty();
                  }
                  try {
                    final games = await Provider.of<GameService>(context, listen: false).searchGames(
                      textEditingValue.text,
                      limit: 15,
                    );
                    
                    return games.map<GameModel>((g) => GameModel(
                      id: g.idGame.toString(),
                      title: g.name,
                      imageUrl: g.imageUrl,
                    )).toList();
                  } catch (e) {
                    debugPrint('Error fetching game suggestions: $e');
                  }
                  return const Iterable<GameModel>.empty();
                },
                displayStringForOption: (GameModel option) => option.title,
                onSelected: widget.onGameSelected,
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.darkerBlue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Rechercher un jeu...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      suffixIcon: widget.selectedGame != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                controller.clear();
                                widget.onGameSelected(null);
                              },
                            )
                          : null,
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: AppTheme.darkerBlue,
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 250,
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              title: Text(option.title, style: const TextStyle(color: Colors.white)),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Hours drum/wheel picker — same label format, narrower width
        SizedBox(
          width: 110,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Heures jouées',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.darkerBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: 20,
                      diameterRatio: 1,
                      perspective: 0.003,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        widget.hoursController.text = index.toString();
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Center(
                          child: Text(
                            '$index h',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        childCount: _maxHours + 1,
                      ),
                    ),
                    // Visual hint for scrolling
                    const Positioned(
                      right: 8,
                      child: Icon(
                        Icons.unfold_more,
                        color: Colors.white24,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
