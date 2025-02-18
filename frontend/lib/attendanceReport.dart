import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/AttendanceModel.dart';
import 'package:frontend/Models/ErrorObject.dart';
import 'package:frontend/Utility.dart';
import 'package:frontend/widgets/Button.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';
import 'package:frontend/widgets/Table.dart';
import 'package:frontend/widgets/TextField.dart';
import 'package:path_provider/path_provider.dart';
import 'Services/attendanceService.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({super.key});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  ErrorObject error = ErrorObject(title: '', message: '');
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool dataFetched = false;
  String path = '';
  List<AttendanceModel> attendanceList = [];
  List<DataColumn> columns = [];
  List<DataRow> rows = [];

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ScaffoldPage(
      title: 'Attendance Report',
      error: error,
      body: Column(
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date from'),
                      Textfield(
                        label: "From",
                        readOnly: true,
                        width: screenSize.width * 0.35,
                        controller: TextEditingController(
                          text: displayDate(startDate),
                        ),
                        onTap: () async {
                          await selectDate(context).then((value) {
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
                      Text('Date to'),
                      Textfield(
                        label: "To",
                        readOnly: true,
                        width: screenSize.width * 0.35,
                        controller: TextEditingController(
                          text: displayDate(endDate),
                        ),
                        onTap: () async {
                          await selectDate(context).then((value) {
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
                    onPressed: () async {
                      await downloadReport(
                              formatDate(startDate), formatDate(endDate))
                          .then((result) async {
                        if (result!.isNotEmpty) {
                          setState(() {
                            dataFetched = true;
                            path = path;
                            attendanceList = result;
                            columns = [
                              DataColumn(label: Text('Attendance Date')),
                              DataColumn(label: Text('Employee')),
                              DataColumn(label: Text('Attendance Type')),
                              DataColumn(label: Text('Check-in Photo')),
                              DataColumn(label: Text('Check-in Time')),
                              DataColumn(label: Text('Check-out Photo')),
                              DataColumn(label: Text('Check-out Time')),
                              DataColumn(label: Text('Latitude')),
                              DataColumn(label: Text('Longitude')),
                            ];
                          });
                        }
                      });
                      rows = attendanceList.map((attendance) {
                        return DataRow(
                          cells: [
                            DataCell(
                                Text(displayDate(attendance.attendanceDate))),
                            DataCell(Text(attendance.employeeId.toString())),
                            DataCell(Text(attendance.attendanceType)),
                            DataCell(
                              Image.network(
                                baseImageUrl + attendance.checkInPhoto!,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                            DataCell(Text(displayTime(attendance.checkInTime))),
                            DataCell(
                              Image.network(
                                '$baseImageUrl${attendance.checkOutPhoto}',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                            DataCell(Text(
                                attendance.checkOutTime?.toString() ?? '')),
                            DataCell(Text(attendance.latitude.toString())),
                            DataCell(Text(attendance.longitude.toString())),
                          ],
                        );
                      }).toList();
                    },
                    icon: Icon(
                      Icons.search_rounded,
                      size: 40,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          dataFetched && attendanceList.isNotEmpty
              ? TableWidget(
                  columns: columns,
                  rows: rows,
                  data: attendanceList,
                )
              : Center(
                  child: Text('No data found.'),
                ),
        ],
      ),
    );
  }

  Future<List<List<dynamic>>> readExcelFile(List<int> fileName) async {
    try {
      final excel = Excel.decodeBytes(fileName);

      // Extract data from the first sheet
      final List<List<dynamic>> data = [];
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]?.rows ?? []) {
          data.add(row);
        }
        break;
      }

      return data;
    } catch (e) {
      return [];
    }
  }

  excelFile() {
    var excel = Excel.createExcel();

    var sheet = excel['mySheet'];
    CellStyle cellStyle = CellStyle(
      bold: true,
      italic: true,
      textWrapping: TextWrapping.WrapText,
      fontFamily: getFontFamily(FontFamily.Comic_Sans_MS),
      rotation: 0,
    );
    var cell = sheet.cell(CellIndex.indexByString("A1"));
    cell.value = TextCellValue("Heya How are you I am fine ok goood night");
    cell.cellStyle = cellStyle;

    var cell2 = sheet.cell(CellIndex.indexByString("E5"));
    cell2.value = TextCellValue("Heya How night");
    cell2.cellStyle = cellStyle;

    String outputFile = "/Users/kawal/Desktop/git_projects/r.xlsx";

    //stopwatch.reset();
    List<int>? fileBytes = excel.save();
    //print('saving executed in ${stopwatch.elapsed}');
    if (fileBytes != null) {
      File(outputFile)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }
}
