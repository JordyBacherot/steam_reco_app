import 'package:flutter/material.dart';

/// A standardized title widget for grouping content into sections.
class SectionTitle extends StatelessWidget {
  /// The display text for the section header.
  final String title;
  
  /// Amount of padding to apply above the title.
  final double topPadding;
  
  /// Amount of padding to apply below the title.
  final double bottomPadding;

  const SectionTitle({
    super.key,
    required this.title,
    this.topPadding = 0,
    this.bottomPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
      ),
    );
  }
}
