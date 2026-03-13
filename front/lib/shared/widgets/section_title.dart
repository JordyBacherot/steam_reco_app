import 'package:flutter/material.dart';

/// A standardized title widget for sections across the app.
class SectionTitle extends StatelessWidget {
  final String title;
  final double topPadding;
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
