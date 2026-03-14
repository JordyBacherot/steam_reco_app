import 'package:flutter/material.dart';
import 'package:front/features/profile/widgets/delete_account_dialog.dart';

/// Button for permanently deleting the user's account.
class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => DeleteAccountDialog.show(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(
            color: Colors.red.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: const Text('SUPPRIMER MON COMPTE'),
      ),
    );
  }
}
