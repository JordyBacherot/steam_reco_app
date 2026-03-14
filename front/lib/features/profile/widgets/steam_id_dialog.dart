import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/core/theme/app_theme.dart';

/// A dialog that allows users to update their Steam 64 ID.
class SteamIdDialog extends StatefulWidget {
  /// The current Steam ID to show in the input field initially.
  final String initialSteamId;

  const SteamIdDialog({
    super.key,
    required this.initialSteamId,
  });

  /// Static helper to display the dialog.
  static Future<void> show(BuildContext context, String initialSteamId) {
    return showDialog(
      context: context,
      builder: (context) => SteamIdDialog(initialSteamId: initialSteamId),
    );
  }

  @override
  State<SteamIdDialog> createState() => _SteamIdDialogState();
}

/// State for [SteamIdDialog] managing the text input and update request.
class _SteamIdDialogState extends State<SteamIdDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialSteamId == 'Non lié' ? '' : widget.initialSteamId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.darkerBlue,
      title: const Text('Modifier Steam ID', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Ex: 76561197960287930",
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 16),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              iconColor: AppTheme.primaryBlue,
              collapsedIconColor: AppTheme.primaryBlue,
              title: const Text(
                "Où trouver mon Steam ID ?",
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Text(
                    "1. Ouvrez Steam et cliquez sur votre pseudo en haut à droite.\n"
                    "2. Sélectionnez 'Détails du compte'.\n"
                    "3. Votre 'ID Steam' (une suite de 17 chiffres) se trouve en haut de la page, sous le nom de votre compte.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Annuler', style: TextStyle(color: AppTheme.greyText)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: () async {
            final newSteamId = _controller.text.trim();
            if (newSteamId.isNotEmpty) {
              final authService = Provider.of<AuthService>(context, listen: false);
              final success = await authService.updateSteamId(newSteamId);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Steam ID mis à jour')),
                  );
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de la mise à jour')),
                  );
                }
              }
            }
          },
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }
}
