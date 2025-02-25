import 'package:flutter/material.dart';

import '../Utils/formatter.dart';

class ShiftModel {
  int id;
  String name;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int durationHours;
  int port;
  String? portName;

  ShiftModel(
      {required this.id,
      required this.name,
      required this.startTime,
      required this.endTime,
      required this.durationHours,
      required this.port,
      this.portName});

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
        id: json['id'],
        name: json['name'],
        startTime: Formatter.stringToTimeOfDay(json['start_time']),
        endTime: Formatter.stringToTimeOfDay(json['end_time']),
        durationHours: json['duration_hours'],
        port: json['port'],
        portName: json['port_name']);
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'name': name,
        'start_time': '${startTime!.hour}:${startTime!.minute}',
        'end_time': '${endTime!.hour}:${endTime!.minute}',
        'duration_hours': durationHours.toString(),
        'port': port.toString(),
        'port_name': portName
      };
}
