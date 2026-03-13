import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/shared/widgets/app_text_field.dart';

/// The SignInPage allows users to log into the application.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
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
              Text(
                'Connexion',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Steam_icon_logo.svg/512px-Steam_icon_logo.svg.png',
                width: 120,
                height: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 48),

              AppTextField(
                controller: _usernameController,
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
                  final email = _usernameController.text.trim();
                  final password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez remplir tous les champs')),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);
                  
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final success = await authService.signIn(email, password);
                  
                  if (!mounted) return;
                  
                  setState(() => _isLoading = false);

                  if (success) {
                    if (mounted) FocusScope.of(context).unfocus();
                    context.go('/'); 
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Échec de la connexion. Vérifiez vos identifiants.')),
                    );
                  }
                },
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 24),

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
