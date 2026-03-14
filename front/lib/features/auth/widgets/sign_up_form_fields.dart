import 'package:flutter/material.dart';
import 'package:front/shared/widgets/app_text_field.dart';

/// The form fields for the SignUpPage.
class SignUpFormFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const SignUpFormFields({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(controller: usernameController, labelText: 'Username'),
        const SizedBox(height: 16),
        AppTextField(controller: emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        AppTextField(controller: passwordController, labelText: 'Password', obscureText: true),
      ],
    );
  }
}