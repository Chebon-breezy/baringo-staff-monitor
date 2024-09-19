// File: lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final Function(String?) onSaved;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final String? initialValue;

  CustomTextField({
    required this.labelText,
    required this.onSaved,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      maxLines: maxLines,
    );
  }
}
