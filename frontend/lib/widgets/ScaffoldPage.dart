import 'package:flutter/material.dart';
import 'package:frontend/widgets/errorFallback.dart';
import 'package:frontend/widgets/unfocus.dart';

import '../Models/ErrorObject.dart';
import '../Utils/headerClip.dart';
import 'Appbar.dart';

class ScaffoldPage extends StatelessWidget {
  final String title;
  final body;
  final floatingButton;
  final Drawer? drawer;
  final PreferredSizeWidget? bottom;
  final double? bottomHeight;
  final ErrorObject error;
  final bool? showHeaderClip;
  const ScaffoldPage(
      {super.key,
      this.body,
      required this.title,
      this.floatingButton,
      this.bottom,
      this.drawer,
      required this.error,
      this.bottomHeight = 120,
      this.showHeaderClip = false});

  @override
  Widget build(BuildContext context) {
    if (error.title.isNotEmpty) return ErrorFallback(error: error);

    return SafeArea(
        child: UnfocusOnTap(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: bottom == null
            ? Appbar(title: title)
            : PreferredSize(
                preferredSize: Size.fromHeight(bottomHeight!),
                child: Appbar(title: title, bottom: bottom),
              ),
        drawer: drawer,
        floatingActionButton: floatingButton,
        body: Stack(
          children: [
            Visibility(
              visible: showHeaderClip!,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 150),
                painter: RPSCustomPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: body,
            ),
          ],
        ),
      ),
    ));
  }
}
