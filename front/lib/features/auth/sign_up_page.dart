import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/shared/widgets/app_text_field.dart';
import 'package:front/features/auth/widgets/profile_picture_picker.dart';

/// The registration page where new users can create an account.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

/// State for [SignUpPage] managing account creation and profile setup.
class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Création de compte',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              ProfilePicturePicker(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Séléctionner une image (à implémenter)')),
                  );
                },
              ),
              const SizedBox(height: 48),

              AppTextField(
                controller: _usernameController,
                labelText: 'Username',
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 32),

              _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
                onPressed: () async {
                  final username = _usernameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  if (username.isEmpty || email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez remplir les champs obligatoires')),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);
                  
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final success = await authService.signUp(username, email, password);
                  
                  if (!mounted) return;
                  
                  setState(() => _isLoading = false);

                  if (success) {
                    if (mounted) FocusScope.of(context).unfocus();
                    context.go('/');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Échec de la création de compte.')),
                    );
                  }
                },
                child: const Text('Créer un compte'),
              ),
              const SizedBox(height: 24),

              TextButton(
                onPressed: () => context.go('/sign-in'),
                child: const Text(
                  "Vous avez déjà un compte ? Connectez-vous.",
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
