import 'package:flutter/material.dart';
import 'package:frontend/Services/shiftService.dart';
import 'package:frontend/shift.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

import 'Models/ErrorObject.dart';
import 'Models/PortModel.dart';
import 'Models/ShiftModel.dart';
import 'Services/portService.dart';
import 'Utils/constants.dart';
import 'widgets/SpinKit.dart';
import 'Utils/dialogs.dart';
import 'Utils/formatter.dart';
import 'widgets/dropdown.dart';

class ShiftsList extends StatefulWidget {
  final PortModel? port;
  const ShiftsList({super.key, this.port});

  @override
  State<ShiftsList> createState() => _ShiftsListState();
}

class _ShiftsListState extends State<ShiftsList> {
  ErrorObject error = ErrorObject(title: '', message: '');
  List<PortModel> ports = <PortModel>[];
  PortModel? selectedPort;
  Future<List<ShiftModel>>? futureShifts;

  getPorts() async {
    try {
      await getPort().then((ports) {
        setState(() {
          this.ports = ports;
          selectedPort = widget.port;
          if (selectedPort != null) {
            futureShifts = getShiftsByPort(selectedPort!.id);
          }
        });
      });
    } catch (e) {
      setState(() {
        error = ErrorObject(title: 'Error', message: e.toString());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPorts();
  }

  @override
  Widget build(BuildContext context) {
    if (ports.isEmpty) {
      return ScaffoldPage(
        error: error,
        title: 'Shifts List',
        body: const Center(
            child: SpinKit(
          type: spinkitType,
        )),
      );
    }
    return ScaffoldPage(
      error: error,
      title: 'Shifts List',
      floatingButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pushNamed(context, '/shift').then((onValue) {
            setState(() {
              futureShifts = getShiftsByPort(selectedPort!.id);
            });
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropDown(
              items: ports.map((port) => port.name).toList(),
              initialItem: selectedPort?.name,
              title: 'Select Port',
              onValueChanged: (value) {
                setState(() {
                  PortModel port = getPortByName(value!, ports);
                  selectedPort = port;
                  futureShifts = getShiftsByPort(port.id);
                });
              },
            ),
          )),
      body: FutureBuilder<List<ShiftModel>>(
        future: futureShifts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No shift found'));
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height - 231,
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return shiftCard(context, snapshot.data![index]);
                  }),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(
              child: Text('Select Port'),
            );
          }
        },
      ),
    );
  }

  Widget shiftCard(BuildContext context, ShiftModel shift) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(shift.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timings',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Time',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      Formatter.formatTimeOfDay(shift.startTime!, context),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Time',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      Formatter.formatTimeOfDay(shift.endTime!, context),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      shift.durationHours.toString(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Shift(shift: shift),
                    ),
                  ).then((onValue) {
                    setState(() {
                      futureShifts = getShiftsByPort(selectedPort!.id);
                    });
                  });
                },
                child: const Icon(
                  Icons.edit,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () async {
                  await showDialog(
                    context: context,
                    barrierDismissible:
                        false, // User must tap button to close dialog
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Shift'),
                        content: const SingleChildScrollView(
                          child: Text(
                              'Are you sure you want to delete this shift?'),
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
                  ).then((result) async {
                    if (result == true) {
                      await deleteShift(shift.id).then((result) async {
                        setState(() {
                          futureShifts = getShiftsByPort(selectedPort!.id);
                        });
                        await Dialogs.showMessageDialog(
                            context, 'Shift', result);
                      }).catchError(
                        (err) {
                          Dialogs.showMessageDialog(
                              context, 'Shift', err.toString());
                        },
                      );
                    }
                  });
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
