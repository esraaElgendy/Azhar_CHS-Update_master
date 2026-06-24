import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  }) ;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        floatingLabelStyle: theme.inputDecorationTheme.labelStyle,
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.border,
        focusedBorder: theme.inputDecorationTheme.border,
      ),
    );
  }
}
