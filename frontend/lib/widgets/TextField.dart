import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  final String label;
  final controller;
  final double width;
  final int maxLines;
  final keyboardType;
  final bool obscureText;
  final validator;
  final onTap;
  final bool readOnly;
  final onFieldSubmitted;
  final TextStyle? style;
  const Textfield(
      {super.key,
      required this.label,
      this.controller,
      this.width = double.infinity,
      this.maxLines = 1,
      this.keyboardType,
      this.obscureText = false,
      this.validator,
      this.onTap,
      this.readOnly = false,
      this.onFieldSubmitted,
      this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 40,
      width: width,

      margin: const EdgeInsets.fromLTRB(0, 5, 5, 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!, width: 0.5),
          borderRadius: BorderRadius.circular(7),
          color: Colors.white),
      padding: EdgeInsets.only(left: 5),
      child: TextFormField(
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        validator: validator,
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        style: style,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 0.5),
          ),
        ),
      ),
    );
  }
}
