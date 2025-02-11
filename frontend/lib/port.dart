import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/PortModel.dart';
import 'package:frontend/Services/portService.dart';
import 'package:frontend/Utility.dart';
import 'package:frontend/widgets/Button.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

import 'widgets/TextField.dart';
import 'widgets/loading.dart';

class Port extends StatefulWidget {
  final PortModel? port;
  const Port({super.key, this.port});

  @override
  State<Port> createState() => _PortState();
}

class _PortState extends State<Port> {
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
      title: 'Port',
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [
          form(port),
          isSaving ? LoadingWidget() : Container(),
        ]),
      ),
    );
  }

  Widget form(PortModel port) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
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
                  Text('Location'),
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
      isSaving = true;
    });
    port.name = nameController.text;
    port.location = locationController.text;
    if (port.id > 0) {
      await updatePort(port.id, port).then((response) async {
        setState(() {
          isSaving = false;
        });
        await showMessageDialog(context, page, 'Port saved successfuly.');
        Navigator.pop(context);
      }).catchError((err) {
        setState(() {
          isSaving = false;
        });
        showMessageDialog(context, page, err.toString());
      });
    } else {
      await createPort(port).then((response) async {
        setState(() {
          isSaving = false;
        });
        await showMessageDialog(context, page, 'Port saved successfuly.');
        Navigator.pop(context);
      }).catchError((err) {
        setState(() {
          isSaving = false;
        });
        showMessageDialog(context, page, err.toString());
      });
    }
  }
}
