import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final Icon icon;
  final onTap;
  const Tile(
      {super.key,
      required this.text,
      required this.color,
      required this.size,
      required this.icon,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shadowColor: Colors.grey,
        color: color,
        child: SizedBox(
          height: size,
          width: size,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(
                height: 10,
              ),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
