import 'package:flutter/material.dart';

class UnfocusOnTap extends StatelessWidget {
  final Widget child;

  UnfocusOnTap({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild!.unfocus();
        }
      },
      child: child,
    );
  }
}
