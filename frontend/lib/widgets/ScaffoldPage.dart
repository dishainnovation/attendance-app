import 'package:flutter/material.dart';

import 'Appbar.dart';

class ScaffoldPage extends StatelessWidget {
  final String title;
  final body;
  const ScaffoldPage({super.key, this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: Appbar(title: title),
      body: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(8.0), child: body)),
    ));
  }
}
