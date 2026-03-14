import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';

/// A standardized widget for displaying empty states (e.g., no search results, empty library).
class EmptyState extends StatelessWidget {
  /// The message to display to the user.
  final String message;
  
  /// Optional label for a call-to-action button.
  final String? buttonLabel;
  
  /// Callback function triggered when the CTA button is pressed.
  final VoidCallback? onButtonPressed;
  
  /// vertical padding to apply around the content.
  final double verticalPadding;

  const EmptyState({
    super.key,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
    this.verticalPadding = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.greyText, fontSize: 16),
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
