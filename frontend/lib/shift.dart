import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Models/ErrorObject.dart';
import 'Models/PortModel.dart';
import 'Models/ShiftModel.dart';
import 'Services/portService.dart';
import 'Services/shiftService.dart';
import 'Utility.dart';
import 'widgets/Button.dart';
import 'widgets/ScaffoldPage.dart';
import 'widgets/TextField.dart';
import 'widgets/dropdown.dart';
import 'widgets/loading.dart';

class Shift extends StatefulWidget {
  final ShiftModel? shift;
  final PortModel? selectedPort;
  const Shift({super.key, this.selectedPort, this.shift});

  @override
  State<Shift> createState() => _ShiftState();
}

class _ShiftState extends State<Shift> {
  ErrorObject error = ErrorObject(title: '', message: '');
  final formKey = GlobalKey<FormState>();
  String page = 'Shift';
  bool _isSaving = false;

  ShiftModel shift = ShiftModel(
      id: 0,
      name: '',
      startTime: TimeOfDay(hour: 0, minute: 0),
      endTime: TimeOfDay(hour: 0, minute: 0),
      durationHours: 0,
      port: 0);

  TextEditingController nameController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  List<PortModel> ports = <PortModel>[];

  getPorts() async {
    await getPort().then((ports) {
      setState(() {
        this.ports = ports;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getPorts();
    if (widget.shift != null) {
      shift = widget.shift!;
      nameController.text = widget.shift!.name;
      durationController.text = widget.shift!.durationHours.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      error: error,
      title: page,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: form(context, shift),
            ),
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

  Widget form(context, ShiftModel shift) {
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  Text('Start Time'),
                  Textfield(
                    label: 'Start Time',
                    controller: TextEditingController(
                        text: formatTimeOfDay(shift.startTime!, context)),
                    onTap: () async {
                      await selectTime(context, shift.startTime).then((value) {
                        if (value != null) {
                          setState(() {
                            shift.startTime = value;
                            shift.durationHours =
                                shift.endTime!.hour - shift.startTime!.hour;
                            durationController.text =
                                shift.durationHours.toString();
                          });
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select start time';
                      }
                      return null;
                    },
                  ),
                  Text('End Time'),
                  Textfield(
                    label: 'End Time',
                    controller: TextEditingController(
                        text: formatTimeOfDay(shift.endTime!, context)),
                    onTap: () async {
                      await selectTime(context, shift.startTime).then((value) {
                        if (value != null) {
                          setState(() {
                            shift.endTime = value;
                            shift.durationHours =
                                shift.endTime!.hour - shift.startTime!.hour;
                            durationController.text =
                                shift.durationHours.toString();
                          });
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select start time';
                      }
                      return null;
                    },
                  ),
                  Text('Duration Hours'),
                  Textfield(
                    label: 'Geofencing Area (in meters)',
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter duration hours';
                      }
                      return null;
                    },
                  ),
                  Text('Port'),
                  ports.isNotEmpty
                      ? DropDown(
                          items: ports.map((port) => port.name).toList(),
                          initialItem: shift.portName == null
                              ? ports[0].name
                              : shift.portName!,
                          title: 'Select Port',
                          onValueChanged: (value) {
                            setState(() {
                              PortModel port = getPortByName(value!, ports);
                              shift.port = port.id;
                            });
                          },
                        )
                      : Container(
                          height: 50,
                          width: double.infinity,
                          color: Colors.grey[350],
                        ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Button(
            label: 'Save',
            color: Colors.green,
            onPressed: save,
          ),
        ],
      ),
    );
  }

  Future<TimeOfDay?> selectTime(BuildContext context, selectedTime) async {
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: selectedTime);
    return pickedTime;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (shift.port == 0) {
      await showMessageDialog(context, page, 'Please select port.');
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      shift.name = nameController.text;
      shift.durationHours = int.parse(durationController.text);
      shift.portName = ports.firstWhere((port) => port.id == shift.port).name;
      if (shift.id == 0) {
        await createShift(shift).then((response) async {
          setState(() {
            _isSaving = false;
          });
          await showMessageDialog(context, page, 'Shift saved successfuly.');
          Navigator.pop(context);
        }).catchError((err) {
          setState(() {
            _isSaving = false;
          });
          showMessageDialog(context, page, err.toString());
        });
      } else {
        await updateShift(shift.id, shift).then((response) async {
          setState(() {
            _isSaving = false;
          });
          await showMessageDialog(context, page, 'Shift saved successfuly.');
          Navigator.pop(context);
        }).catchError((err) {
          setState(() {
            _isSaving = false;
          });
          showMessageDialog(context, page, err.toString());
        });
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      error = ErrorObject(title: 'Error', message: e.toString());
    }
  }
}
