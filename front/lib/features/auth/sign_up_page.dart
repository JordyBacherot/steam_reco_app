import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/services/auth_service.dart';

/// The SignUpPage allows users to create a new account.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers to retrieve the text entered by the user
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed to prevent memory leaks
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Helper method to build consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Displays the profile picture with an edit badge
  Widget _buildProfilePicture() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: Implement image picker logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Séléctionner une image (à implémenter)')),
          );
        },
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Background avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white70,
              ),
            ),
            // Edit icon badge
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Title
              const Text(
                'Création de compte',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // 2. Profile Picture
              _buildProfilePicture(),
              const SizedBox(height: 48),

              // 3. Input Fields
              _buildTextField(
                controller: _usernameController,
                labelText: 'Username',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // 4. Registration Button
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
                  
                  final authService = context.read<AuthService>();
                  final success = await authService.signUp(username, email, password);
                  
                  if (!mounted) return;
                  
                  setState(() => _isLoading = false);

                  if (success) {
                    // GoRouter will redirect automatically since signUp also signs you in
                    // But we can navigate directly if needed
                    context.go('/');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Échec de la création de compte.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Navigation back to Sign In Page
              TextButton(
                onPressed: () => context.go('/sign-in'),
                child: const Text(
                  "Vous avez déjà un compte ? Connectez-vous.",
                  style: TextStyle(
                    color: Colors.blueAccent,
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
