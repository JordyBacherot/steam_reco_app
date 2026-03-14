import 'package:flutter/material.dart';
import 'package:front/core/theme/app_theme.dart';

/// A standardized text field widget used for user input across the application.
class AppTextField extends StatelessWidget {
  /// Controller for the text being edited.
  final TextEditingController controller;
  
  /// Text that describes the purpose of the field.
  final String labelText;
  
  /// Whether to hide the text being entered (e.g., for passwords).
  final bool obscureText;
  
  /// The type of keyboard to display.
  final TextInputType keyboardType;
  
  /// Temporary text that suggests what the user should enter.
  final String? hintText;
  
  /// An icon to display at the start of the text field.
  final Widget? prefixIcon;
  
  /// An icon to display at the end of the text field.
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppTheme.greyText),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
