import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String label;
  final Color color;
  final double width;
  final double borderRadius;
  final VoidCallback? onPressed;
  const Button(
      {super.key,
      required this.label,
      required this.color,
      this.onPressed,
      this.width = 100,
      this.borderRadius = 10});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      sizeStyle: CupertinoButtonSize.medium,
      borderRadius: BorderRadius.circular(borderRadius),
      onPressed: onPressed,
      color: color,
      child: SizedBox(
        width: width,
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
