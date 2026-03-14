import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/core/theme/app_theme.dart';

/// A confirmation dialog for permanent account deletion.
class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  /// Static helper to display the dialog.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.darkerBlue,
      title: const Text(
        'Supprimer mon compte',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Cette action est irréversible. Toutes vos données, '
        'y compris votre bibliothèque de jeux et vos avis, '
        'seront définitivement supprimées.\n\n'
        'Êtes-vous sûr de vouloir continuer ?',
        style: TextStyle(color: Colors.white70, height: 1.4),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Annuler',
            style: TextStyle(color: AppTheme.greyText),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final authService =
                Provider.of<AuthService>(context, listen: false);
            final success = await authService.deleteAccount();
            if (context.mounted) {
              if (success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Compte supprimé avec succès'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression du compte'),
                  ),
                );
              }
            }
          },
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}
