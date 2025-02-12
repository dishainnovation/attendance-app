import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/Models/Designation.dart';
import 'package:frontend/Services/userNotifier.dart';
import 'package:frontend/widgets/Button.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:provider/provider.dart';
import 'Models/EmployeeModel.dart';
import 'Models/PortModel.dart';
import 'Services/designationService.dart';
import 'Services/employeeService.dart';
import 'Services/portService.dart';
import 'Utility.dart';
import 'widgets/TextField.dart';
import 'widgets/dropdown.dart';
import 'widgets/loading.dart';

class Employee extends StatefulWidget {
  final EmployeeModel? employee;
  final List<EmployeeModel> employeeesList;
  const Employee({super.key, this.employee, required this.employeeesList});

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  final formKey = GlobalKey<FormState>();
  String page = 'Employee';
  bool _isSaving = false;
  List<PortModel> ports = <PortModel>[];
  List<DesignationModel> designations = <DesignationModel>[];

  EmployeeModel employee = EmployeeModel(
      id: 0,
      employeeCode: '',
      name: '',
      mobileNumber: '',
      gender: 'Male',
      password: '',
      designation: null,
      dateOfBirth: formatDate(DateTime.now()),
      dateOfJoining: formatDate(DateTime.now()),
      port: 0,
      portName: '');

  TextEditingController nameController = TextEditingController();

  getPorts() async {
    await getPort().then((ports) {
      setState(() {
        this.ports = ports;
        employee.employeeCode =
            generateEmployeeCode(ports[0].name, widget.employeeesList);
      });
    });
  }

  getDesignationsList() async {
    await getDesignations().then((designations) {
      setState(() {
        this.designations = designations;
        setState(() {
          DesignationModel designation =
              getDesignationByName(designations[0].name, designations);
          employee.designation = designation;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getPorts();
    getDesignationsList();
    if (widget.employee != null) {
      employee = widget.employee!;
      nameController.text = employee.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    EmployeeModel user = context.read<User>().user!;
    if (user.designation!.user_type != 'SUPER_ADMIN') {
      employee.employeeCode =
          generateEmployeeCode(user.portName!, widget.employeeesList);
    }
    return ScaffoldPage(
      title: page,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            form(context, employee, user),
            _isSaving == true
                ? Positioned.fill(
                    child: LoadingWidget(message: 'Saving...'),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget form(
      BuildContext context, EmployeeModel employee, EmployeeModel user) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name'),
                  Textfield(
                    label: 'Name',
                    controller: nameController,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    onFieldSubmitted: (value) {
                      setState(() {
                        employee.name = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  Text('Port'),
                  user.designation?.user_type != 'SUPER_ADMIN'
                      ? Textfield(
                          label: 'Port',
                          readOnly: true,
                          controller:
                              TextEditingController(text: user.portName),
                        )
                      : ports.isNotEmpty
                          ? DropDown(
                              items: ports.map((port) => port.name).toList(),
                              initialItem: employee.port == 0
                                  ? user.portName
                                  : employee.portName!,
                              title: 'Select Port',
                              onValueChanged: (value) {
                                setState(() {
                                  PortModel port = getPortByName(value!, ports);
                                  employee.port = port.id;
                                  employee.portName = port.name;
                                  if (employee.id == 0) {
                                    employee.employeeCode =
                                        generateEmployeeCode(
                                            port.name, widget.employeeesList);
                                  }
                                });
                              },
                            )
                          : Container(
                              height: 50,
                              width: double.infinity,
                              color: Colors.grey[350],
                            ),
                  Text('Code'),
                  Textfield(
                    label: 'Code',
                    readOnly: true,
                    controller:
                        TextEditingController(text: employee.employeeCode),
                    onFieldSubmitted: (value) {
                      setState(() {
                        employee.name = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  Text('Password'),
                  Textfield(
                    label: 'Password',
                    obscureText: true,
                    controller: TextEditingController(text: employee.password),
                    onFieldSubmitted: (value) {
                      setState(() {
                        employee.password = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender'),
                          SizedBox(
                            width: 150,
                            child: DropDown(
                              items: ['Male', 'Female'],
                              initialItem: 'Male',
                              title: 'Select Gender',
                              onValueChanged: (value) {
                                setState(() {
                                  employee.gender = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mobile Number'),
                          Textfield(
                            label: 'Mobile Number',
                            width: 200,
                            controller: TextEditingController(
                                text: employee.mobileNumber),
                            onFieldSubmitted: (value) {
                              setState(() {
                                employee.mobileNumber = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter mobile number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date of Birth'),
                            Textfield(
                              label: 'Date of Birth',
                              readOnly: true,
                              width: 160,
                              controller: TextEditingController(
                                text: employee.dateOfBirth,
                              ),
                              onFieldSubmitted: (value) {
                                setState(() {
                                  employee.dateOfBirth = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter name';
                                }
                                return null;
                              },
                              onTap: () async {
                                await selectDate(context).then((value) {
                                  setState(() {
                                    employee.dateOfBirth = formatDate(value);
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hire Date'),
                            Textfield(
                              label: 'Hire Date',
                              readOnly: true,
                              width: 160,
                              controller: TextEditingController(
                                text: employee.dateOfJoining,
                              ),
                              onFieldSubmitted: (value) {
                                setState(() {
                                  employee.dateOfJoining = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter name';
                                }
                                return null;
                              },
                              onTap: () async {
                                await selectDate(context).then((value) {
                                  setState(() {
                                    employee.dateOfJoining = formatDate(value);
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('Designation'),
                  designations.isNotEmpty
                      ? DropDown(
                          items: designations
                              .map((designation) => designation.name)
                              .toList(),
                          initialItem: employee.designation == null
                              ? designations[0].name
                              : employee.designation!.name,
                          title: 'Select Designation',
                          onValueChanged: (value) {
                            setState(() {
                              DesignationModel designation =
                                  getDesignationByName(value!, designations);
                              employee.designation = designation;
                            });
                          },
                        )
                      : Container(
                          height: 50,
                          width: double.infinity,
                          color: Colors.grey[350],
                        ),
                  SizedBox(height: 10),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Container(
                            width: 210,
                            height: 210,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[600]!),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: employee.employeePhoto == null
                                ? Icon(
                                    Icons.image,
                                    size: 200,
                                    color: Colors.grey,
                                  )
                                : Image.network(
                                    baseImageUrl + employee.employeePhoto!.path,
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, event) {
                                      if (event == null) {
                                        return child;
                                      }
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/attendance.png',
                                        width: 200,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Button(
                              width: 180,
                              label: 'Capture Photo',
                              color: Colors.blue,
                              onPressed: () async {
                                final image = await captureImage();
                                setState(() {
                                  employee.profileImage = image!.path;
                                  employee.employeePhoto = File(image.path);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Button(label: 'Save', color: Colors.green, onPressed: save),
        ],
      ),
    );
  }

  save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (employee.employeePhoto == null) {
      showSnackBar(
          context, 'Employee', 'Please take a selfie.', ContentType.failure);
      return;
    }
    setState(() {
      _isSaving = true;
    });
    employee.name = nameController.text;
    if (employee.id == 0) {
      await createEmployee(employee, employee.employeePhoto!).then((value) {
        setState(() {
          _isSaving = false;
        });
        showSnackBar(context, 'Employee', 'Employee saved successfuly.',
            ContentType.success);
        Navigator.pop(context);
      }).catchError((err) {
        setState(() {
          _isSaving = false;
        });
        showSnackBar(context, 'Employee', err.toString(), ContentType.failure);
      });
    } else {
      await updateEmployee(employee.id, employee, employee.employeePhoto!)
          .then((value) {
        setState(() {
          _isSaving = false;
        });
        showSnackBar(context, 'Employee', 'Employee updated successfuly.',
            ContentType.success);
        Navigator.pop(context);
      }).catchError((err) {
        setState(() {
          _isSaving = false;
        });
        showSnackBar(context, 'Employee', err.toString(), ContentType.failure);
      });
    }
  }

  Future<DateTime> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    return picked ?? DateTime.now();
  }
}
