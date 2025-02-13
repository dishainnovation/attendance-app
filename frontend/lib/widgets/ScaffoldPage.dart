import 'package:flutter/material.dart';
import 'package:frontend/widgets/unfocus.dart';

import 'Appbar.dart';

class ScaffoldPage extends StatelessWidget {
  final String title;
  final body;
  final floatingButton;
  final Drawer? drawer;
  final PreferredSizeWidget? bottom;
  const ScaffoldPage(
      {super.key,
      this.body,
      required this.title,
      this.floatingButton,
      this.bottom,
      this.drawer});

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              body,
              Container(
                width: MediaQuery.of(context).size.width,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
