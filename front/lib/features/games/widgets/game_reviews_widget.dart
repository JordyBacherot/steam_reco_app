import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/game_service.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/models/review_model.dart';
import 'package:front/core/theme/app_theme.dart';
import 'dart:developer';

class GameReviewsWidget extends StatefulWidget {
  final int gameId;

  const GameReviewsWidget({super.key, required this.gameId});

  @override
  State<GameReviewsWidget> createState() => _GameReviewsWidgetState();
}

class _GameReviewsWidgetState extends State<GameReviewsWidget> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isPosting = false;
  bool _isLoading = true;
  List<ReviewModel> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final gameService = context.read<GameService>();
      final reviews = await gameService.getReviewsForGame(widget.gameId.toString());
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching reviews: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview() async {
    final text = _reviewController.text.trim();
    if (text.isEmpty) return;

    if (text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre avis est trop court (minimum 2 caractères).')),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour poster un avis.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final gameService = context.read<GameService>();
      final success = await gameService.postReview(
        gameId: widget.gameId.toString(),
        userId: userId,
        text: text,
      );

      if (success && mounted) {
        _reviewController.clear();
        _fetchReviews();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avis posté avec succès !')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi de l\'avis.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Building GameReviewsWidget for gameId: ${widget.gameId}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "Avis des joueurs :",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Review Input field
        TextField(
          controller: _reviewController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Laissez votre avis ici...",
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _reviewController,
            builder: (context, value, child) {
              final canPost = value.text.trim().length >= 2;
              return ElevatedButton(
                onPressed: (_isPosting || !canPost) ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canPost ? AppTheme.primaryBlue : Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
                child: _isPosting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Poster l'avis"),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Aucun avis pour le moment. Soyez le premier à en poster un !",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white10),
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.username,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 4),
                    Text(review.text),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
