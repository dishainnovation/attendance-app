import 'package:flutter/material.dart';

import '../Utility.dart';
import 'SpinKit.dart';

class LoadingWidget extends StatelessWidget {
  final String message;

  LoadingWidget({this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKit(
              type: spinkitType,
            ),
            SizedBox(height: 16.0),
            Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
