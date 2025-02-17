import 'package:flutter/material.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Services/userNotifier.dart';
import 'package:frontend/screen.dart';
import 'package:provider/provider.dart';

import 'Utility.dart';
import 'register.dart';
import 'widgets/Button.dart';
import 'widgets/TextField.dart';
import 'Services/loginService.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  onLogin(BuildContext context) async {
    if (userIdController.text.isEmpty) {
      showMessageDialog(context, 'Login', 'Please enter user id.');
      return false;
    }
    if (passwordController.text.isEmpty) {
      showMessageDialog(context, 'Login', 'Please enter password.');
      return false;
    }

    try {
      final user = await login(userIdController.text, passwordController.text);

      context.read<User>().user = EmployeeModel.fromJson(user.toJson());
      storeUserInfo(user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Screen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/loginback.png'),
                  )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Image.asset(
                              'assets/images/attendance.png',
                              width: 100,
                            ),
                            SizedBox(height: 20),
                            Text('Login',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(height: 40),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Textfield(
                                  label: 'User ID',
                                  controller: userIdController,
                                  width: 250,
                                ),
                                Textfield(
                                    label: 'Password',
                                    controller: passwordController,
                                    width: 250,
                                    obscureText: true),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Button(
                                  color: const Color.fromARGB(255, 20, 69, 23),
                                  label: 'Login',
                                  width: 220,
                                  borderRadius: 30,
                                  onPressed: () {
                                    onLogin(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                Text('Not registered yet?',
                    style: TextStyle(color: Colors.grey)),
                SizedBox(
                  height: 30,
                ),
                Button(
                  color: Colors.green,
                  label: 'Register Now',
                  width: 170,
                  borderRadius: 30,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterPage(
                                isProfile: false,
                              )),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
