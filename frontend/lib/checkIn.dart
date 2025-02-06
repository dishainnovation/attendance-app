import 'package:flutter/material.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:image_picker/image_picker.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    // final pickedFile = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => CustomCamera()),
    // );

    // if (pickedFile != null) {
    //   print('Picked image path: $pickedFile');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      title: 'Check In',
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pickImage(context),
          child: Text('Take a Selfie'),
        ),
      ),
    );
  }
}
