import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/AttendanceModel.dart';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Models/ErrorObject.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:frontend/widgets/Table.dart';
import 'package:frontend/widgets/TextField.dart';
import 'package:frontend/Utils/formatter.dart';
import 'package:provider/provider.dart';
import 'Models/PortModel.dart';
import 'Services/attendanceService.dart';
import 'Services/portService.dart';
import 'Services/userNotifier.dart';
import 'Utils/constants.dart';
import 'Utils/dialogs.dart';
import 'widgets/dropdown.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({super.key});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  ErrorObject error = ErrorObject(title: '', message: '');
  EmployeeModel? user;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  bool dataFetched = false;
  String path = '';
  List<AttendanceModel> attendanceList = [];
  List<DataColumn> columns = [];
  List<DataRow> rows = [];
  bool filtersExpanded = false;
  bool filterByPort = false;
  bool filterByEmployee = false;
  List<PortModel> ports = <PortModel>[];
  int? selectedPort;

  TextEditingController employeeController = TextEditingController();

  getPorts() async {
    await getPort().then((ports) {
      setState(() {
        this.ports = ports;
      });
    }).catchError((e) {
      error = ErrorObject(title: 'Error', message: e.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    user = context.read<User>().user;
    getPorts();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ScaffoldPage(
      title: 'Attendance Report',
      error: error,
      body: Column(
        children: [
          filterCard(screenSize, context),
          const SizedBox(height: 10),
          dataFetched && attendanceList.isNotEmpty
              ? TableWidget(
                  columns: columns,
                  rows: rows,
                  data: attendanceList,
                  fileName:
                      'Attendance Report_${Formatter.displayDate(startDate).replaceAll('-', '_')}_${Formatter.displayDate(endDate).replaceAll('-', '_')}',
                )
              : const Center(
                  child: Text('No data found.'),
                ),
        ],
      ),
    );
  }

  Card filterCard(Size screenSize, BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            datefilterWidget(screenSize, context),
            Visibility(
              visible: user!.designation!.user_type == 'SUPER_ADMIN' ||
                  user!.designation!.user_type == 'ADMIN',
              child: Row(
                children: [
                  const Text('More filters'),
                  InkWell(
                    onTap: () {
                      setState(() {
                        filtersExpanded = !filtersExpanded;
                      });
                    },
                    child: Icon(
                      filtersExpanded
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 35,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: filtersExpanded,
              child: Column(
                children: [
                  Visibility(
                    visible: user!.designation!.user_type == 'SUPER_ADMIN',
                    child: portFilterWidget(screenSize),
                  ),
                  Visibility(
                    visible: user!.designation!.user_type == 'SUPER_ADMIN' ||
                        user!.designation!.user_type == 'ADMIN',
                    child: employeeFilterWidget(screenSize),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Row employeeFilterWidget(Size screenSize) {
    return Row(
      children: [
        Checkbox(
          value: filterByEmployee,
          onChanged: (value) {
            setState(() {
              filterByEmployee = value!;
              employeeController.text = '';
            });
          },
        ),
        const Text('Employee'),
        const SizedBox(width: 10),
        filterByEmployee
            ? SizedBox(
                width: screenSize.width * 0.5,
                child: Textfield(
                  label: 'Employee',
                  controller: employeeController,
                ),
              )
            : Container(),
      ],
    );
  }

  Row portFilterWidget(Size screenSize) {
    return Row(
      children: [
        Checkbox(
          value: filterByPort,
          onChanged: (value) {
            setState(() {
              filterByPort = value!;
              selectedPort = null;
            });
          },
        ),
        const Text('Port'),
        const SizedBox(width: 10),
        ports.isNotEmpty && filterByPort
            ? SizedBox(
                width: screenSize.width * 0.6,
                child: DropDown(
                  items: ports.map((port) => port.name).toList(),
                  initialItem: user!.portName,
                  title: 'Select Port',
                  onValueChanged: (value) {
                    PortModel port = getPortByName(value!, ports);
                    setState(() {
                      selectedPort = port.id;
                    });
                  },
                ),
              )
            : Container(),
      ],
    );
  }

  Row datefilterWidget(Size screenSize, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date from'),
            Textfield(
              label: 'From',
              readOnly: true,
              width: screenSize.width * 0.35,
              controller: TextEditingController(
                text: Formatter.displayDate(startDate),
              ),
              onTap: () async {
                await Dialogs.selectDate(context).then((value) {
                  setState(() {
                    startDate = value;
                  });
                });
              },
              onFieldSubmitted: (value) {
                setState(() {
                  startDate = DateTime.parse(value);
                });
              },
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date to'),
            Textfield(
              label: 'To',
              readOnly: true,
              width: screenSize.width * 0.35,
              controller: TextEditingController(
                text: Formatter.displayDate(endDate),
              ),
              onTap: () async {
                await Dialogs.selectDate(context).then((value) {
                  setState(() {
                    startDate = value;
                  });
                });
              },
              onFieldSubmitted: (value) {
                setState(() {
                  endDate = DateTime.parse(value);
                });
              },
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            searchData();
          },
          icon: const Icon(
            Icons.search_rounded,
            size: 40,
          ),
        )
      ],
    );
  }

  searchData() async {
    await downloadReport(
            Formatter.formatDate(startDate),
            Formatter.formatDate(endDate),
            selectedPort,
            employeeController.text)
        .then((result) async {
      if (result.isNotEmpty) {
        setState(() {
          dataFetched = true;
          path = path;
          attendanceList = result;
          columns = [
            const DataColumn(label: Text('Date')),
            const DataColumn(label: Text('Employee')),
            const DataColumn(label: Text('Type')),
            const DataColumn(label: Text('Check-in Photo')),
            const DataColumn(label: Text('Check-in Time')),
            const DataColumn(label: Text('Check-out Photo')),
            const DataColumn(label: Text('Check-out Time')),
            const DataColumn(label: Text('Latitude')),
            const DataColumn(label: Text('Longitude')),
          ];
        });
      } else {
        setState(() {
          attendanceList = [];
        });
      }
    });
    rows = attendanceList.map((attendance) {
      return DataRow(
        cells: [
          DataCell(Text(Formatter.displayDate(attendance.attendanceDate))),
          DataCell(Text(attendance.employeeId.name)),
          DataCell(Text(attendance.attendanceType)),
          DataCell(
            Image.network(
              attendance.checkInPhoto!,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  size: 50,
                  color: Colors.grey,
                );
              },
            ),
          ),
          DataCell(Text(Formatter.displayTime(attendance.checkInTime))),
          DataCell(
            Image.network(
              attendance.checkOutPhoto!,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  size: 50,
                  color: Colors.grey,
                );
              },
            ),
          ),
          DataCell(Text(attendance.checkOutTime?.toString() ?? '')),
          DataCell(Text(attendance.latitude.toString())),
          DataCell(Text(attendance.longitude.toString())),
        ],
      );
    }).toList();
  }
}
