import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';

/// A fullscreen widget used to indicate a background operation is in progress.
class LoadingView extends StatelessWidget {
  /// The message to display alongside the loading indicator.
  final String message;

  const LoadingView({
    super.key,
    this.message = "Analyzing...",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryBlue),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          )
        ],
      ),
    );
  }
}

/// A fullscreen widget used to display an error state with a retry option.
class ErrorView extends StatelessWidget {
  /// The error message to display.
  final String message;
  
  /// Callback function triggered when the user taps the 'Retry' button.
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }
}
