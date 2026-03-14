import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/features/auth/widgets/sign_in_form_fields.dart';
import 'package:front/features/auth/widgets/sign_in_button.dart';
import 'package:front/shared/widgets/steam_logo.dart';

/// The login page allowing users to authenticate with their email and password.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Logo (SVG)
              Center(
                child: SteamLogo(
                  size: 120,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),

              // Title
              Text(
                'Connexion',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 32),

              // Form fields
              SignInFormFields(
                emailController: _emailController,
                passwordController: _passwordController,
              ),
              const SizedBox(height: 32),

              // Login button
              SignInButton(
                emailController: _emailController,
                passwordController: _passwordController,
              ),
              const SizedBox(height: 24),

              // Navigate to Sign Up page
              TextButton(
                onPressed: () => context.push('/sign-up'),
                child: const Text(
                  "Pas de compte ? s'en créer un",
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}