import 'package:flutter/material.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Services/employeeService.dart';
import 'package:frontend/Services/userNotifier.dart';
import 'package:frontend/employee.dart';
import 'package:frontend/widgets/employeeCard.dart';
import 'package:provider/provider.dart';

import 'Models/ErrorObject.dart';
import 'Models/PortModel.dart';
import 'Services/portService.dart';
import 'Utils/constants.dart';
import 'widgets/ScaffoldPage.dart';
import 'widgets/SpinKit.dart';
import 'Utils/dialogs.dart';
import 'Utils/formatter.dart';
import 'widgets/dropdown.dart';

class EmployeesList extends StatefulWidget {
  const EmployeesList({super.key});

  @override
  State<EmployeesList> createState() => _EmployeesListState();
}

class _EmployeesListState extends State<EmployeesList> {
  EmployeeModel? user;
  ErrorObject error = ErrorObject(title: '', message: '');
  List<EmployeeModel> allEmployeesList = [];
  List<EmployeeModel> filteredEmployeesList = [];
  bool isLoading = false;
  List<PortModel> ports = <PortModel>[];
  PortModel? selectedPort;

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

  getPorts() async {
    try {
      await getPort().then((ports) {
        setState(() {
          this.ports = ports;
          selectedPort = ports.firstWhere((port) => port.id == user!.port);
        });
      });
    } catch (e) {
      setState(() {
        error = ErrorObject(title: 'Error', message: e.toString());
      });
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    await getPorts();
    if (selectedPort != null) await getEmployees(selectedPort!.id);
  }

  getEmployees(int portId) async {
    await getEmployeesByPort(portId).then((employees) {
      setState(() {
        allEmployeesList = employees;
        filteredEmployeesList = employees;
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
        error = ErrorObject(title: 'Error', message: e.toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    user = context.read<User>().user!;
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
      error: error,
      title: 'Employees List',
      bottomHeight: 180,
      bottom: filterBar(),
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height - 231,
        child: isLoading
            ? const Center(
                child: SpinKit(
                type: spinkitType,
              ))
            : filteredEmployeesList.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredEmployeesList.length,
                    itemBuilder: (context, index) {
                      return EmployeeCard(
                        employee: filteredEmployeesList[index],
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Employee(
                                employee: filteredEmployeesList[index],
                                employeeesList: allEmployeesList,
                              ),
                            ),
                          ).then((onValue) {
                            setState(() {});
                          });
                        },
                        onDelete: () async {
                          await showDialog(
                            context: context,
                            barrierDismissible:
                                false, // User must tap button to close dialog
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Employee'),
                                content: const SingleChildScrollView(
                                  child: Text(
                                      'Are you sure you want to delete this employee?'),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Approve'),
                                    onPressed: () async {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              );
                            },
                          ).then((value) async {
                            if (value) {
                              await deleteEmployee(
                                      filteredEmployeesList[index].id)
                                  .then((result) async {
                                await Dialogs.showMessageDialog(
                                    context, 'Employee', result);
                                getData();
                              }).catchError(
                                (err) {
                                  Dialogs.showMessageDialog(
                                      context, 'Employee', err.toString());
                                },
                              );
                            }
                          });
                        },
                        isActionable: true,
                      );
                    })
                : const Center(
                    child: Text('No records found.'),
                  ),
      ),
    );
  }

  PreferredSize filterBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(180),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Visibility(
              visible: user!.designation!.user_type == 'SUPER_ADMIN',
              child: DropDown(
                items: ports.map((port) => port.name).toList(),
                initialItem: selectedPort?.name,
                title: 'Select Port',
                onValueChanged: (value) async {
                  PortModel port = getPortByName(value!, ports);
                  await getEmployees(port.id);
                  setState(() {
                    selectedPort = port;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.all(8.0),
                fillColor: Colors.white,
              ),
              onChanged: filterItems,
            ),
          ],
        ),
      ),
    );
  }
}
