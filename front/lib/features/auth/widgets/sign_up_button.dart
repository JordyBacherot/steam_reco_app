import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/core/theme/app_theme.dart';

/// A modular sign-up button handling loading, validation, and sign-up logic.
class SignUpButton extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final File? profileImage;

  const SignUpButton({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    this.profileImage,
  });

  @override
  State<SignUpButton> createState() => _SignUpButtonState();
}

class _SignUpButtonState extends State<SignUpButton> {
  bool _isLoading = false;

  Future<void> _signUp() async {
    final username = widget.usernameController.text.trim();
    final email = widget.emailController.text.trim();
    final password = widget.passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir les champs obligatoires')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.signUp(
      username,
      email,
      password,
      //profileImage: widget.profileImage, // optional
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      FocusScope.of(context).unfocus();
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de la création de compte.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
            onPressed: _signUp,
            child: const Text('Créer un compte'),
          );
  }
}