import 'package:flutter/material.dart';
import 'package:frontend/Models/PortModel.dart';
import 'package:frontend/Services/portService.dart';
import 'package:frontend/widgets/Button.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

import 'Models/ErrorObject.dart';
import 'widgets/TextField.dart';
import 'Utils/dialogs.dart';
import 'widgets/loading.dart';

class Port extends StatefulWidget {
  final PortModel? port;
  const Port({super.key, this.port});

  @override
  State<Port> createState() => _PortState();
}

class _PortState extends State<Port> {
  ErrorObject error = ErrorObject(title: '', message: '');
  final formKey = GlobalKey<FormState>();
  String page = 'Port';
  bool isSaving = false;
  PortModel port = PortModel(id: 0, name: '', location: '');
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.port != null) {
      port = widget.port!;
      nameController.text = widget.port!.name;
      locationController.text = widget.port!.location;
    } else {
      port = PortModel(id: 0, name: '', location: '');
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
              child: form(port),
            ),
            isSaving == true
                ? Positioned.fill(
                    child: LoadingWidget(message: 'Saving...'),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget form(PortModel port) {
    return Form(
      key: formKey,
      child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Name'),
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
                        const Text('Location'),
                        Textfield(
                          label: 'Location',
                          controller: locationController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Button(
                  label: 'Save',
                  color: Colors.green,
                  onPressed: save,
                ),
              ],
            );
          }),
    );
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isSaving = true;
    });
    try {
      port.name = nameController.text;
      port.location = locationController.text;
      if (port.id > 0) {
        await updatePort(port.id, port).then((response) async {
          setState(() {
            isSaving = false;
          });
          await Dialogs.showMessageDialog(
              context, page, 'Port saved successfuly.');
          Navigator.pop(context);
        }).catchError((err) {
          setState(() {
            isSaving = false;
          });
          Dialogs.showMessageDialog(context, page, err.toString());
        });
      } else {
        await createPort(port).then((response) async {
          setState(() {
            isSaving = false;
          });
          await Dialogs.showMessageDialog(
              context, page, 'Port saved successfuly.');
          Navigator.pop(context);
        }).catchError((err) {
          setState(() {
            isSaving = false;
          });
          Dialogs.showMessageDialog(context, page, err.toString());
        });
      }
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      error = ErrorObject(title: 'Error', message: e.toString());
    }
  }
}
