import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/terminal.dart';
import 'package:frontend/widgets/ScaffoldPage.dart';

import 'Models/PortModel.dart';
import 'Models/SiteModel.dart';
import 'Services/portService.dart';
import 'Services/terminalService.dart';
import 'Utility.dart';
import 'widgets/dropdown.dart';

class TerminalsList extends StatefulWidget {
  final PortModel? port;
  const TerminalsList({super.key, this.port});

  @override
  State<TerminalsList> createState() => _TerminalsListState();
}

class _TerminalsListState extends State<TerminalsList> {
  List<PortModel> ports = <PortModel>[];
  Future<List<SiteModel>>? futureSite;
  PortModel? selectedPort;

  getPorts() async {
    await getPort().then((ports) {
      setState(() {
        this.ports = ports;
        selectedPort = widget.port;
        if (selectedPort != null) {
          futureSite = getSitesByPort(selectedPort!.id);
        }
      });
    });
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
        title: 'Terminals List',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return ScaffoldPage(
      title: 'Terminals List',
      floatingButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Terminal(selectedPort: selectedPort),
            ),
          ).then((onValue) {
            setState(() {});
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
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
                  futureSite = getSitesByPort(port.id);
                });
              },
            ),
          )),
      body: SizedBox(
        height: MediaQuery.of(context).size.height - 231,
        child: FutureBuilder<List<SiteModel>>(
            future: futureSite,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Center(child: Text('No terminals found'));
                }
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.78,
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return terminalCard(snapshot.data![index]);
                      }),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Center(
                  child: Text('Select Port'),
                );
                // return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  Widget terminalCard(SiteModel site) {
    return Card(
      color: Colors.white,
      child: ListTile(
        isThreeLine: true,
        contentPadding: EdgeInsets.all(10),
        title: Text(
          site.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geo Coordinates:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Divider(
              thickness: 1,
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${site.latitude}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    Text(
                      'Longitude',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${site.longitude}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
                      builder: (context) => Terminal(site: site),
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
              InkWell(
                onTap: () => delete(site),
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

  Future delete(SiteModel site) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terminal'),
          content: SingleChildScrollView(
            child: Text('Are you sure you want to delete this terminal?'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () async {
                await deleteSite(site.id).then((result) async {
                  setState(() {});
                  Navigator.of(context).pop();
                }).catchError(
                  (err) {
                    showMessageDialog(context, 'Terminal', err.toString());
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
  }
}
