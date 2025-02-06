import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Utility.dart';
import 'home.dart';
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
  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  onLogin() async {
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(user));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
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
                          Icon(Icons.calendar_month,
                              size: 100, color: Colors.orange),
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
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Button(
                                color: Colors.blue[900]!,
                                label: 'Login',
                                width: 220,
                                borderRadius: 30,
                                onPressed: onLogin,
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
              Text('Not registered yet?', style: TextStyle(color: Colors.grey)),
              SizedBox(
                height: 30,
              ),
              Button(
                color: Colors.blue,
                label: 'Register Now',
                width: 170,
                borderRadius: 30,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
