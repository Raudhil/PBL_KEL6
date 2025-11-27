import 'package:flutter/material.dart';
import 'package:jawara/theme/app_colors.dart';

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.validator,
    this.suffixIcon,
  });

  InputDecoration _decoration(BuildContext context) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      hintText: label,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      filled: false,
      // transparent background, subtle border to be visible on primary background
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.18), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.6),
      ),
      suffixIcon: suffixIcon,
      errorText: errorText,
      errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: _decoration(context),
    );
  }
}
