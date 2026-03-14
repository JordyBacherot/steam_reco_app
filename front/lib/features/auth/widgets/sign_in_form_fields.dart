import 'package:flutter/material.dart';
import 'package:front/shared/widgets/app_text_field.dart';

/// A reusable widget containing the email and password fields for signing in.
class SignInFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const SignInFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email input
        AppTextField(
          controller: emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Password input
        AppTextField(
          controller: passwordController,
          labelText: 'Password',
          obscureText: true,
        ),
      ],
    );
  }
}