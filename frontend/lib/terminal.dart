import 'package:flutter/material.dart';
import 'package:frontend/Models/SiteModel.dart';
import 'package:frontend/Services/terminalService.dart';
import 'package:frontend/widgets/dropdown.dart';
import 'package:frontend/widgets/loading.dart';

import 'Models/ErrorObject.dart';
import 'Models/PortModel.dart';
import 'Services/portService.dart';
import 'Utility.dart';
import 'widgets/Button.dart';
import 'widgets/ScaffoldPage.dart';
import 'widgets/TextField.dart';

class Terminal extends StatefulWidget {
  final SiteModel? site;
  final PortModel? selectedPort;
  const Terminal({super.key, this.site, this.selectedPort});

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  ErrorObject error = ErrorObject(title: '', message: '');
  final formKey = GlobalKey<FormState>();
  String page = 'Terminal';
  bool _isSaving = false;
  SiteModel site = SiteModel(
      id: 0,
      name: '',
      latitude: 0.00,
      longitude: 0.00,
      port: 0,
      geoFenceArea: 0);
  TextEditingController nameController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController geoFenceController = TextEditingController();
  List<PortModel> ports = <PortModel>[];

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
    getPorts();
    if (widget.site != null) {
      site = widget.site!;
      nameController.text = widget.site!.name;
      latitudeController.text = widget.site!.latitude.toString();
      longitudeController.text = widget.site!.longitude.toString();
      geoFenceController.text = widget.site!.geoFenceArea.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPort != null) {
      site.port = widget.selectedPort!.id;
      site.portName = widget.selectedPort!.name;
    }
    return ScaffoldPage(
      error: error,
      title: 'Terminal',
      body: SizedBox(
        height: MediaQuery.of(context).size.height - 170,
        child: Stack(
          children: [
            form(site),
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

  Widget form(SiteModel site) {
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
                  Text('Latitude'),
                  Textfield(
                    label: 'Latitude',
                    controller: latitudeController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter latitude';
                      }
                      return null;
                    },
                  ),
                  Text('Longitude'),
                  Textfield(
                    label: 'Longitude',
                    controller: longitudeController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter longitude';
                      }
                      return null;
                    },
                  ),
                  Text('Geofencing Area (in meters)'),
                  Textfield(
                    label: 'Geofencing Area (in meters)',
                    controller: geoFenceController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter geofencing area';
                      }
                      return null;
                    },
                  ),
                  Text('Port'),
                  ports.isNotEmpty
                      ? DropDown(
                          items: ports.map((port) => port.name).toList(),
                          initialItem: site.portName == null
                              ? ports[0].name
                              : site.portName!,
                          title: 'Select Port',
                          onValueChanged: (value) {
                            setState(() {
                              PortModel port = getPortByName(value!, ports);
                              site.port = port.id;
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

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      site.name = nameController.text;
      site.latitude = double.parse(latitudeController.text);
      site.longitude = double.parse(longitudeController.text);
      site.geoFenceArea = int.parse(geoFenceController.text);
      site.portName = ports.firstWhere((port) => port.id == site.port).name;
      if (site.id == 0) {
        await createSite(site).then((response) async {
          setState(() {
            _isSaving = false;
          });
          await showMessageDialog(context, page, 'Terminal saved successfuly.');
          Navigator.pop(context);
        }).catchError((err) {
          showMessageDialog(context, page, err.toString());
        });
      } else {
        await updateSite(site.id, site).then((response) async {
          setState(() {
            _isSaving = false;
          });
          await showMessageDialog(context, page, 'Terminal saved successfuly.');
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
        _isSaving = true;
      });
      error = ErrorObject(title: 'Error', message: e.toString());
    }
  }
}
