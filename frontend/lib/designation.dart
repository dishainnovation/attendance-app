import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/Designation.dart';
import 'package:frontend/Services/designationService.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

import 'Models/ErrorObject.dart';
import 'Utility.dart';
import 'widgets/Button.dart';
import 'widgets/TextField.dart';
import 'widgets/dropdown.dart';

class Designation extends StatefulWidget {
  final DesignationModel? designation;
  const Designation({super.key, this.designation});

  @override
  State<Designation> createState() => _DesignationState();
}

class _DesignationState extends State<Designation> {
  ErrorObject error = ErrorObject(title: '', message: '');
  final formKey = GlobalKey<FormState>();
  String page = 'Designation';
  bool isSaving = false;
  DesignationModel designation = DesignationModel(id: 0, name: '');
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.designation != null) {
      setState(() {
        designation = widget.designation!;
        nameController.text = designation.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      error: error,
      title: page,
      body: designationForm(),
    );
  }

  Form designationForm() {
    return Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                    DropDown(
                      items: ['SUPER_ADMIN', 'ADMIN', 'SUPERVISOR', 'USER'],
                      initialItem: designation.user_type,
                      title: 'Select Designation',
                      onValueChanged: (value) {
                        setState(() {
                          designation.user_type = value;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Remote Checkin'),
                      subtitle:
                          Text('Allow remote checkin for this designation'),
                      value: designation.remote_checkin,
                      onChanged: (value) {
                        setState(() {
                          designation.remote_checkin = value!;
                        });
                      },
                    )
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
        ));
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isSaving = true;
    });
    try {
      designation.name = nameController.text;
      if (designation.id > 0) {
        await updateDesignation(designation.id, designation)
            .then((response) async {
          setState(() {
            isSaving = false;
          });
          await showMessageDialog(
              context, page, 'Designation saved successfuly.');
          Navigator.pop(context);
        }).catchError((err) {
          setState(() {
            isSaving = false;
          });
          showMessageDialog(context, page, err.toString());
        });
      } else {
        await createDesignation(designation).then((response) async {
          setState(() {
            isSaving = false;
          });
          await showMessageDialog(
              context, page, 'Designation saved successfuly.');
          Navigator.pop(context);
        }).catchError((err) {
          setState(() {
            isSaving = false;
          });
          showMessageDialog(context, page, err.toString());
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
