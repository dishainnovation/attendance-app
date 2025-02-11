import 'package:flutter/material.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Services/employeeService.dart';
import 'package:frontend/Services/userNotifier.dart';
import 'package:frontend/employee.dart';
import 'package:provider/provider.dart';

import 'Utility.dart';
import 'widgets/ScaffoldPage.dart';

class EmployeesList extends StatefulWidget {
  const EmployeesList({super.key});

  @override
  State<EmployeesList> createState() => _EmployeesListState();
}

class _EmployeesListState extends State<EmployeesList> {
  List<EmployeeModel> allEmployeesList = [];
  List<EmployeeModel> filteredEmployeesList = [];

  filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredEmployeesList = allEmployeesList;
      });
    } else {
      setState(() {
        filteredEmployeesList = allEmployeesList
            .where(
                (item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  getData() async {
    await getEmployees().then((employees) {
      setState(() {
        allEmployeesList = employees;
        filteredEmployeesList = employees;
      });
    }).catchError((onError) => throw Exception(onError));
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    EmployeeModel user = context.read<User>().user!;
    filteredEmployeesList = filteredEmployeesList
        .map((emp) => emp)
        .where((emp) => emp.port == user.port)
        .toList();
    return ScaffoldPage(
      title: 'Employees List',
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding: EdgeInsets.all(8.0),
              fillColor: Colors.white,
            ),
            onChanged: filterItems,
          ),
        ),
      ),
      floatingButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Employee(
                employeeesList: allEmployeesList,
              ),
            ),
          ).then((onValue) {
            setState(() {});
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView.builder(
            itemCount: filteredEmployeesList.length,
            itemBuilder: (context, index) {
              return employeeCard(filteredEmployeesList[index]);
            }),
      ),
    );
  }

  Widget employeeCard(EmployeeModel employee) {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.centerLeft,
        title: Text(employee.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee.designation!.name,
              style: TextStyle(color: Colors.blueAccent),
            ),
            Text(
              employee.mobileNumber,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: actions(employee),
        children: <Widget>[
          Divider(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 17.0,
              right: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Code: ${employee.employeeCode}',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  'Port: ${employee.portName}',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 17.0),
            child: Text(
              'Gender: ${employee.gender}',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Divider(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 17.0,
              right: 10,
              bottom: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Birth : ${displayDate(DateTime.parse(employee.dateOfBirth))}',
                  style: TextStyle(color: Colors.grey),
                ),
                Container(
                  color: Colors.grey,
                  width: 1,
                  height: 20,
                ),
                Text(
                  'Hire Date: ${displayDate(DateTime.parse(employee.dateOfJoining))}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget actions(EmployeeModel employee) {
    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Employee(
                    employee: employee,
                    employeeesList: allEmployeesList,
                  ),
                ),
              ).then((onValue) {
                setState(() {});
              });
            },
            child: Icon(
              Icons.edit,
              color: Colors.green,
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () async {
              await showDialog(
                context: context,
                barrierDismissible:
                    false, // User must tap button to close dialog
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Employee'),
                    content: SingleChildScrollView(
                      child: Text(
                          'Are you sure you want to delete this employee?'),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Approve'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await deleteEmployee(employee.id)
                              .then((result) async {
                            await showMessageDialog(
                                context, 'Employee', result);
                            setState(() {});
                          }).catchError(
                            (err) {
                              showMessageDialog(
                                  context, 'Employee', err.toString());
                            },
                          );
                        },
                      ),
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
