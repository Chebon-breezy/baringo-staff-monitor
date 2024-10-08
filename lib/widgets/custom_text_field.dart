import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final Function(String?) onSaved;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final String? initialValue;
  final TextInputType? keyboardType; // Add this line

  CustomTextField({
    required this.labelText,
    required this.onSaved,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.initialValue,
    this.keyboardType, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      maxLines: maxLines,
      keyboardType: keyboardType, // Add this line
    );
  }
}
