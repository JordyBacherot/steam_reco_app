import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';

/// Button for logging the user out of the app.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          context.read<AuthService>().logout();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: BorderSide(
            color: Colors.redAccent.withOpacity(0.5), 
            width: 1.5
          ),
        ),
        child: const Text('SE DÉCONNECTER'),
      ),
    );
  }
}