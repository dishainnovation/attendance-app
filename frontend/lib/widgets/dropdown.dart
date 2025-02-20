import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropDown extends StatelessWidget {
  final List<String> items;
  final String? initialItem;
  final onValueChanged;
  final String title;
  final bool? enabled;
  const DropDown(
      {super.key,
      required this.items,
      this.initialItem,
      this.onValueChanged,
      required this.title,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    double dropDownHeight = 200;
    if (items.length > 10) {
      dropDownHeight = 500;
    } else {
      dropDownHeight = items.length * 70;
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!, width: 0.5),
          borderRadius: BorderRadius.circular(7)),
      child: CustomDropdown<String>(
        enabled: enabled!,
        hintText: title,
        items: items,
        initialItem: initialItem,
        overlayHeight: dropDownHeight,
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
