import 'package:flutter/cupertino.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'Utility.dart';
import 'Models/UserModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? user;

  getUserData() async {
    await getUserInfo().then((value) => setState(() {
          user = value;
        }));
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      title: user != null ? user!.name : 'Home',
      body: Center(child: Text('Home')),
    );
  }
}
