import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Models/Designation.dart';
import 'package:frontend/Services/designationService.dart';
import 'package:frontend/designation.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

import 'Models/ErrorObject.dart';
import 'Utility.dart';
import 'widgets/SpinKit.dart';

class DesignationsList extends StatefulWidget {
  const DesignationsList({super.key});

  @override
  State<DesignationsList> createState() => _DesignationsListState();
}

class _DesignationsListState extends State<DesignationsList> {
  ErrorObject error = ErrorObject(title: '', message: '');
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      error: error,
      title: 'Designation',
      floatingButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pushNamed(context, '/designation').then((onValue) {
            setState(() {});
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<DesignationModel>>(
        future: getDesignations(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(child: Text('No designation found'));
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return portCard(snapshot.data![index]);
                  }),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(
                child: SpinKit(
              type: spinkitType,
            ));
          }
        },
      ),
    );
  }

  Widget portCard(DesignationModel designation) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(designation.name),
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
                      builder: (context) =>
                          Designation(designation: designation),
                    ),
                  ).then((onValue) {
                    setState(() {});
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () async {
                  await showDialog(
                    context: context,
                    barrierDismissible:
                        false, // User must tap button to close dialog
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Designation'),
                        content: SingleChildScrollView(
                          child: Text(
                              'Are you sure you want to delete this designation?'),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Approve'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await deleteDesignation(designation.id)
                                  .then((result) async {
                                await showMessageDialog(
                                    context, 'Designation', result);
                                setState(() {});
                              }).catchError(
                                (err) {
                                  showMessageDialog(
                                      context, 'Designation', err.toString());
                                },
                              );
                            },
                          ),
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(
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
