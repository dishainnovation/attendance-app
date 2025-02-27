import 'package:flutter/material.dart';
import 'package:frontend/Models/EmployeeModel.dart';

import '../Utils/constants.dart';
import '../Utils/formatter.dart';

class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isActionable;
  const EmployeeCard(
      {super.key,
      required this.employee,
      this.onEdit,
      this.onDelete,
      required this.isActionable});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Card(
          color: Colors.white,
          child: ExpansionTile(
            initiallyExpanded: !isActionable,
            enabled: isActionable,
            showTrailingIcon: false,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.centerLeft,
            childrenPadding: const EdgeInsets.only(
              left: 17.0,
              right: 15,
              bottom: 5,
            ),
            title: Text(employee.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.designation!.name,
                          style: const TextStyle(color: Colors.blueAccent),
                        ),
                        Text(
                          employee.mobileNumber,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: employee.profileImage != null
                            ? NetworkImage(employee.profileImage!)
                            : const AssetImage('assets/images/no-image.jpg'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              const Divider(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code: ${employee.employeeCode}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Port: ${employee.portName}',
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Text(
                'Gender: ${employee.gender}',
                style: const TextStyle(color: Colors.grey),
              ),
              const Divider(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Birth : ${Formatter.displayDate(DateTime.parse(employee.dateOfBirth))}',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    color: Colors.grey,
                    width: 1,
                    height: 20,
                  ),
                  Text(
                    'Hire Date: ${Formatter.displayDate(DateTime.parse(employee.dateOfJoining))}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        isActionable
            ? Positioned(
                top: 0,
                right: 8,
                child: popupMenu(),
              )
            : Container(),
      ],
    );
  }

  Widget popupMenu() {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: onEdit,
          value: 1,
          child: const Row(
            children: [
              Icon(
                Icons.edit,
                color: Colors.green,
              ),
              SizedBox(
                width: 10,
              ),
              Text('Edit')
            ],
          ),
        ),
        PopupMenuItem(
          onTap: onDelete,
          value: 2,
          child: const Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.red,
              ),
              SizedBox(
                width: 10,
              ),
              Text('Delete')
            ],
          ),
        ),
      ],
      offset: const Offset(0, 10),
      color: Colors.white,
      elevation: 2,
    );
  }
}
