import 'package:flutter/material.dart';
import 'package:frontend/widgets/errorFallback.dart';
import 'package:frontend/widgets/unfocus.dart';

import '../Models/ErrorObject.dart';
import 'Appbar.dart';

class ScaffoldPage extends StatelessWidget {
  final String title;
  final body;
  final floatingButton;
  final Drawer? drawer;
  final PreferredSizeWidget? bottom;
  final ErrorObject error;
  const ScaffoldPage(
      {super.key,
      this.body,
      required this.title,
      this.floatingButton,
      this.bottom,
      this.drawer,
      required this.error});

  @override
  Widget build(BuildContext context) {
    if (error.title.isNotEmpty) return ErrorFallback(error: error);
    return SafeArea(
        child: UnfocusOnTap(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.green[50],
        appBar: bottom == null
            ? Appbar(title: title)
            : PreferredSize(
                preferredSize: Size.fromHeight(120.0),
                child: Appbar(title: title, bottom: bottom),
              ),
        drawer: drawer,
        floatingActionButton: floatingButton,
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: body,
        ),
      ),
    ));
  }
}
