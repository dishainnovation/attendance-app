import 'package:flutter/material.dart';
import 'package:frontend/terminalsList.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

import 'Models/ErrorObject.dart';
import 'Models/PortModel.dart';
import 'Services/portService.dart';
import 'Utils/constants.dart';
import 'port.dart';
import 'widgets/SpinKit.dart';
import 'Utils/dialogs.dart';

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
        child: const Icon(Icons.add, color: Colors.white),
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
            return const Center(child: Text('No ports found'));
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
          return const Center(
              child: SpinKit(
            type: spinkitType,
          ));
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
          style: const TextStyle(color: Colors.grey),
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
                        title: const Text('Port'),
                        content: const SingleChildScrollView(
                          child: Text(
                              'Are you sure you want to delete this port?'),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Approve'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await deletePort(port.id).then((result) async {
                                await Dialogs.showMessageDialog(
                                    context, 'Port', result);
                                setState(() {});
                              }).catchError(
                                (err) {
                                  Dialogs.showMessageDialog(
                                      context, 'Port', err.toString());
                                },
                              );
                            },
                          ),
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
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
