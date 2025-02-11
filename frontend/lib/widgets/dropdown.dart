import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropDown extends StatelessWidget {
  final List<String> items;
  final String? initialItem;
  final onValueChanged;
  final String title;
  const DropDown(
      {super.key,
      required this.items,
      this.initialItem,
      this.onValueChanged,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!, width: 0.5),
          borderRadius: BorderRadius.circular(7)),
      child: CustomDropdown<String>(
        hintText: title,
        items: items,
        initialItem: initialItem,
        overlayHeight: 200,
        onChanged: onValueChanged,
        headerBuilder: (context, selectedItem, enabled) {
          return Text(
            selectedItem.toString(),
          );
        },
      ),
    );
  }
}
