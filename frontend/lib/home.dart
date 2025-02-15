import 'package:flutter/material.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:provider/provider.dart';
import 'Models/ErrorObject.dart';
import 'Services/navigationService.dart';
import 'Services/userNotifier.dart';
import 'Models/EmployeeModel.dart';
import 'widgets/tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ErrorObject error = ErrorObject(title: '', message: '');
  double cardSize = 100;
  List<Widget> functionTiles = [];
  List<Widget> reportsTiles = [];
  EmployeeModel? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = context.read<User>().user!;
    setTiles(context);
    return ScaffoldPage(
      error: error,
      title: 'Attendance Tracker',
      body: homeContent(),
    );
  }

  Column homeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        user == null
            ? Container()
            : Text(
                'Welcome ${user!.name}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
        Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.green,
          ),
          child: user == null
              ? Container()
              : Text(
                  user!.designation!.name.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
        ),
        SizedBox(height: 30),
        Divider(),
        SizedBox(height: 10),
        functionGrid(),
        Divider(),
        Text('Reports'),
        SizedBox(height: 20),
        reportsGrid(),
      ],
    );
  }

  Widget functionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns in the functionGrid
        crossAxisSpacing: 10.0, // Space between columns
        mainAxisSpacing: 10.0, // Space between rows
      ),
      itemCount: functionTiles.length,
      itemBuilder: (context, index) {
        return functionTiles[index];
      },
    );
  }

  Widget reportsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns in the functionGrid
        crossAxisSpacing: 10.0, // Space between columns
        mainAxisSpacing: 10.0, // Space between rows
      ),
      itemCount: reportsTiles.length,
      itemBuilder: (context, index) {
        return reportsTiles[index];
      },
    );
  }

  setTiles(BuildContext context) {
    functionTiles = [
      Tile(
          text: 'Employees',
          color: Colors.green,
          icon: Icon(
            Icons.groups,
            size: 50,
            color: Colors.white,
          ),
          size: 100,
          onTap: () => NavigationService.navigateTo('/employees-list')),
      Tile(
        text: 'Terminals',
        color: Colors.deepOrange,
        icon: Icon(
          Icons.account_tree_outlined,
          size: 50,
          color: Colors.white,
        ),
        size: 100,
        onTap: () => NavigationService.navigateTo('/terminals-list'),
      ),
    ];
    reportsTiles = [
      Tile(
        text: 'Attendance',
        color: Colors.lightBlueAccent,
        icon: Icon(
          Icons.calendar_month,
          size: 50,
          color: Colors.white,
        ),
        size: 100,
      ),
    ];
  }
}
