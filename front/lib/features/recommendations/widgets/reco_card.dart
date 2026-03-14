import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';

/// A card used to display a recommendation option or game.
/// Can be enabled or disabled. If disabled, a reason is displayed under the title.
class RecoCard extends StatelessWidget {
  /// The title of the recommendation
  final String title;

  /// The description of the recommendation
  final String description;

  /// Whether the card is interactable
  final bool isEnabled;

  /// The callback when the card is tapped
  final VoidCallback onPressed;

  /// Optional widget shown on the left of the title (icon/logo)
  final Widget? leading;

  /// Text explaining why the card is disabled (shown only if `isEnabled` is false)
  final String disabledReason;

  const RecoCard({
    super.key,
    required this.title,
    required this.description,
    required this.disabledReason,
    required this.isEnabled,
    required this.onPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6, // visually dim if disabled
      child: Card(
        color: AppTheme.darkerBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isEnabled ? AppTheme.primaryBlue : Colors.grey[800]!,
            width: isEnabled ? 2 : 1,
          ),
        ),
        elevation: isEnabled ? 8 : 0,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with optional leading widget
                Row(
                  children: [
                    leading ?? const SizedBox.shrink(),
                    if (leading != null) const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description of the card
                Text(
                  description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.greyText),
                ),

                // Disabled reason, shown only if the card is disabled
                if (!isEnabled && disabledReason.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    disabledReason,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}