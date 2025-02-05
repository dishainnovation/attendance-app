import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  final String label;
  final controller;
  final double width;
  final int maxLines;
  final keyboardType;
  const Textfield(
      {super.key,
      required this.label,
      this.controller,
      this.width = double.infinity,
      this.maxLines = 1,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 40,
      width: width,
      margin: const EdgeInsets.fromLTRB(0, 5, 5, 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!, width: 0.5),
          borderRadius: BorderRadius.circular(7)),
      padding: EdgeInsets.all(2),
      child: CupertinoTextField(
          controller: controller,
          placeholder: label,
          maxLines: maxLines,
          keyboardType: keyboardType),
    );
  }
}
