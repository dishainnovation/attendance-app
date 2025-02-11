import 'package:flutter/material.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Utility.dart';
import 'Services/navigationService.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:frontend/widgets/tile.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  double cardSize = 100;
  List<Widget> functionTiles = [];
  List<Widget> reportsTiles = [];
  EmployeeModel? employee;

  @override
  void initState() {
    super.initState();
    getUserInfo().then((user) {
      setState(() {
        employee = user;
      });
    });
    setTiles();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return ScaffoldPage(
      title: 'Attendance Tracker',
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 80,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[900]!, Colors.green],
                  ),
                ),
                child: Text(
                  'Attendance Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Designations'),
              leading: Icon(
                Icons.approval,
              ),
              onTap: () {
                Navigator.pop(context);
                NavigationService.navigateTo('/designations-list');
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          employee == null
              ? Container()
              : Text(
                  'Welcome ${employee!.name}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.green,
            ),
            child: employee == null
                ? Container()
                : Text(
                    employee!.designationName.toString(),
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
          SizedBox(
            height: screenSize.height * (functionTiles.length - 1) / 10,
            width: screenSize.width,
            child: functionGrid(),
          ),
          Divider(),
          Text('Reports'),
          SizedBox(height: 20),
          SizedBox(
            height: screenSize.height * 0.2,
            width: screenSize.width,
            child: reportsGrid(),
          ),
        ],
      ),
    );
  }

  Widget functionGrid() {
    return GridView.builder(
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

  setTiles() {
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
        onTap: () => NavigationService.navigateTo('/employees-list'),
      ),
      Tile(
        text: 'Ports',
        color: Colors.blue,
        icon: Icon(
          Icons.directions_boat,
          size: 50,
          color: Colors.white,
        ),
        size: 100,
        onTap: () => NavigationService.navigateTo('/ports-list'),
      ),
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
      Tile(
        text: 'Shifts',
        color: Colors.amber,
        icon: Icon(
          Icons.pending_actions,
          size: 50,
          color: Colors.white,
        ),
        size: 100,
        onTap: () => NavigationService.navigateTo('/shifts-list'),
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
