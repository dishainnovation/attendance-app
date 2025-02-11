import 'package:flutter/material.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      title: 'Check In',
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: Text('Take a Selfie'),
        ),
      ),
    );
  }
}
