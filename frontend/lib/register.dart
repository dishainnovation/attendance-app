import 'package:flutter/material.dart';
import 'package:frontend/widgets/Appbar.dart';
import 'package:frontend/widgets/TextField.dart';

import 'Models/EmployeeModel.dart';

class RegisterPage extends StatefulWidget {
  final bool isProfile;
  final EmployeeModel? employee;
  const RegisterPage({super.key, required this.isProfile, this.employee});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: widget.isProfile == true ? Appbar(title: 'Profile') : null,
        body: body(),
      ),
    );
  }

  Widget body() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          widget.isProfile == true
              ? Container()
              : Text(
                  'Register',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
          employeeForm(),
        ],
      ),
    );
  }

  Widget employeeForm() {
    Size screenSize = MediaQuery.of(context).size;
    return Card(
      color: Colors.white,
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Name'),
                  SizedBox(width: 10),
                  Textfield(
                    controller: nameController,
                    label: 'Name',
                    width: screenSize.width * 0.6,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
