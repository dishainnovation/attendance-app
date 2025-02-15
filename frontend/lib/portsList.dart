import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Utility.dart';
import 'package:frontend/terminalsList.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

import 'Models/ErrorObject.dart';
import 'Models/PortModel.dart';
import 'Services/portService.dart';
import 'port.dart';

class Portslist extends StatefulWidget {
  const Portslist({super.key});

  @override
  State<Portslist> createState() => _PortslistState();
}

class _PortslistState extends State<Portslist> {
  ErrorObject error = ErrorObject(title: '', message: '');
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      error: error,
      title: 'Ports List',
      floatingButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pushNamed(context, '/port').then((onValue) {
            setState(() {});
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: portsList(),
    );
  }

  FutureBuilder<List<PortModel>> portsList() {
    return FutureBuilder<List<PortModel>>(
      future: getPort(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(child: Text('No ports found'));
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
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget portCard(PortModel port) {
    return Card(
      color: Colors.white,
      child: ListTile(
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TerminalsList(port: port),
            ),
          );
        },
        title: Text(port.name),
        subtitle: Text(
          port.location,
          style: TextStyle(color: Colors.grey),
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
                      builder: (context) => Port(port: port),
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
                        title: Text('Port'),
                        content: SingleChildScrollView(
                          child: Text(
                              'Are you sure you want to delete this port?'),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Approve'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await deletePort(port.id).then((result) async {
                                await showMessageDialog(
                                    context, 'Port', result);
                                setState(() {});
                              }).catchError(
                                (err) {
                                  showMessageDialog(
                                      context, 'Port', err.toString());
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
