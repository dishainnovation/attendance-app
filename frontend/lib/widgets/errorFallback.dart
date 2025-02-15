import 'package:flutter/material.dart';
import 'package:frontend/Models/ErrorObject.dart';

class ErrorFallback extends StatelessWidget {
  final ErrorObject error;

  const ErrorFallback({Key? key, required this.error}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text(
                  error.title,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  error.message,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
