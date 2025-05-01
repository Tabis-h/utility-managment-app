import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final TextInputType textInputType;
  final bool isPass;
  final IconData icon;
  final bool isPasswordVisible; // Add this parameter
  final VoidCallback? onVisibilityChanged; // Add this parameter

  const TextFieldInput({
    Key? key,
    required this.textEditingController,
    required this.hintText,
    required this.textInputType,
    this.isPass = false,
    required this.icon,
    this.isPasswordVisible = false, // Default value
    this.onVisibilityChanged, // Optional callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: isPass
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onVisibilityChanged,
        )
            : null,
      ),
      keyboardType: textInputType,
      obscureText: isPass && !isPasswordVisible, // Control visibility
    );
  }
}