import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/core/theme/app_theme.dart';
import 'package:front/features/auth/widgets/profile_picture_picker_wrapper.dart';
import 'package:front/features/auth/widgets/sign_up_form_fields.dart';
import 'package:front/features/auth/widgets/sign_up_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ProfilePicturePickerWrapper _pictureWrapper = const ProfilePicturePickerWrapper();

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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
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

              // Profile picture
              _pictureWrapper,
              const SizedBox(height: 48),

              // Form fields
              SignUpFormFields(
                usernameController: _usernameController,
                emailController: _emailController,
                passwordController: _passwordController,
              ),
              const SizedBox(height: 32),

              // Sign-up button
              SignUpButton(
                usernameController: _usernameController,
                emailController: _emailController,
                passwordController: _passwordController
                //profileImage: _pictureWrapper.selectedImage,zzzzzz
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