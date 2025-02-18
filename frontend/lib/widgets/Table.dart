import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class TableWidget extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final List<dynamic> data;
  const TableWidget(
      {super.key,
      required this.columns,
      required this.rows,
      required this.data});

  @override
  Widget build(BuildContext context) {
    return columns.isEmpty
        ? Center(
            child: Text('No columns supplied.'),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  color: Colors.white,
                  child: DataTable(
                    border: TableBorder.all(
                        color: Colors.grey,
                        width: 0.5,
                        borderRadius: BorderRadius.circular(10)),
                    columnSpacing: 16.0,
                    dataRowMaxHeight: 60.0,
                    headingRowHeight: 40,
                    headingRowColor: WidgetStateColor.resolveWith(
                        (states) => Colors.green.shade100),
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                    columns: columns,
                    rows: rows,
                  ),
                ),
              ),
              IconButton(
                color: Colors.white,
                iconSize: 40,
                onPressed: () async {
                  await downloadExcelFile(context);
                },
                icon: Icon(
                  Icons.download_for_offline_rounded,
                  color: Colors.green[900],
                ),
              ),
            ],
          );
  }

  Future<String> createExcelFile() async {
    // Create a new Excel document
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    List<TextCellValue> colHeaders = [];
    for (var column in columns) {
      colHeaders.add(TextCellValue((column.label as Text).data!));
    }

    sheet.appendRow(colHeaders);

    for (var row in rows) {
      List<CellValue> rowData = [];
      String text = '';
      for (var cell in row.cells) {
        if (cell.child is Text) {
          text = (cell.child as Text).data!;
        } else if (cell.child is Image) {
          Image img = cell.child as Image;
          text = (img.image as NetworkImage).url;
        }
        CellValue celV = TextCellValue(text);
        rowData.add(celV);
      }
      sheet.appendRow(rowData);
    }
    // Get the temporary directory
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/data.xlsx';

    // Write the Excel document to a file
    final List<int> bytes = excel.encode()!;
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return filePath;
  }

  Future<void> downloadExcelFile(BuildContext context) async {
    try {
      final String filePath = await createExcelFile();
      await OpenFile.open(filePath);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel file created and saved at $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create Excel file: $e')));
    }
  }
}
