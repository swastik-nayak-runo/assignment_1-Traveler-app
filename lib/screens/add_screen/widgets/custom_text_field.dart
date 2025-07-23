import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.showLabel,
    this.labelText,
  });

  final TextEditingController controller;
  final String hintText;
  final bool? showLabel;
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        isDense: true,
        labelText: showLabel != null ? labelText : null,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
