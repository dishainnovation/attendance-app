import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/Models/ShiftModel.dart';

import '../Utility.dart';

String url = '${baseUrl}shift/';
Uri uri = Uri.parse(url);

Future<List<ShiftModel>> getShift() async {
  try {
    final response =
        await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<ShiftModel> employees = data.map((emp) {
        return ShiftModel.fromJson(emp as Map<String, dynamic>);
      }).toList();
      return employees;
    } else {
      throw Exception('Failed to load shift: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<ShiftModel> createShift(ShiftModel shift) async {
  try {
    shift.toJson();
    var request = await http.post(uri, body: shift.toJson());

    if (request.statusCode == 201) {
      return ShiftModel.fromJson(
          jsonDecode(request.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to save shift: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<ShiftModel> updateShift(int id, ShiftModel shift) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = await http.put(uriPut, body: shift.toJson());

    if (request.statusCode == 200) {
      Map<String, dynamic> data =
          jsonDecode(request.body) as Map<String, dynamic>;
      return ShiftModel.fromJson(data);
    } else {
      throw Exception('Failed to save shift: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<String> deleteShift(int id) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = await http.delete(uriPut);

    if (request.statusCode == 204) {
      return 'Shift deleted successfuly.';
    } else {
      throw Exception('Failed to save shift: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

ShiftModel getShiftByName(String name, List<ShiftModel> shifts) {
  return shifts.firstWhere((shift) => shift.name == name);
}

Future<List<ShiftModel>> getShiftsByPort(int portId) async {
  try {
    uri = Uri.parse('$url?port_id=$portId');
    final response =
        await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<ShiftModel> shifts = data.map((shift) {
        return ShiftModel.fromJson(shift as Map<String, dynamic>);
      }).toList();
      return shifts;
    } else {
      throw Exception('Failed to load shifts: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<ShiftModel?> getCurrentShift(int portId, TimeOfDay time) async {
  ShiftModel shift;
  List<ShiftModel> shifts = await getShift();
  shift = shifts.firstWhere((s) => s.port == portId); //
  return shift;
}
