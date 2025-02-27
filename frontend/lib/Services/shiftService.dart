import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/Models/ShiftModel.dart';

import 'dioClient.dart';

final String baseUrl = 'shift/';

final InterceptedClient client = InterceptedClient();
Future<List<ShiftModel>> getShift() async {
  return _handleGetRequest(baseUrl);
}

Future<ShiftModel> createShift(ShiftModel shift) async {
  return _handlePostRequest(baseUrl, shift.toJson());
}

Future<ShiftModel> updateShift(int id, ShiftModel shift) async {
  return _handlePutRequest('$baseUrl$id/', shift.toJson());
}

Future<String> deleteShift(int id) async {
  return _handleDeleteRequest('$baseUrl$id/');
}

ShiftModel getShiftByName(String name, List<ShiftModel> shifts) {
  return shifts.firstWhere((shift) => shift.name == name);
}

Future<List<ShiftModel>> getShiftById(int id) async {
  return _handleGetRequest('$baseUrl?id=$id');
}

Future<List<ShiftModel>> getShiftsByPort(int portId) async {
  return _handleGetRequest('$baseUrl?port_id=$portId');
}

Future<ShiftModel?> getCurrentShift(int portId, TimeOfDay time) async {
  try {
    List<ShiftModel> shifts = await getShiftsByPort(portId);
    return shifts.firstWhere(
        (s) => time.isAfter(s.startTime!) && time.isBefore(s.endTime!));
  } catch (e) {
    return null;
  }
}

Future<List<ShiftModel>> _handleGetRequest(String endpoint) async {
  try {
    Uri uri = Uri.parse(endpoint);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ShiftModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred during GET request: $e');
  }
}

Future<ShiftModel> _handlePostRequest(
    String endpoint, Map<String, dynamic> body) async {
  try {
    Uri uri = Uri.parse(endpoint);
    final response = await client.post(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 201) {
      return ShiftModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create data: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred during POST request: $e');
  }
}

Future<ShiftModel> _handlePutRequest(
    String endpoint, Map<String, dynamic> body) async {
  try {
    Uri uri = Uri.parse(endpoint);
    final response = await client.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return ShiftModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update data: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred during PUT request: $e');
  }
}

Future<String> _handleDeleteRequest(String endpoint) async {
  try {
    Uri uri = Uri.parse(endpoint);
    final response = await client.delete(uri);

    if (response.statusCode == 204) {
      return 'Shift deleted successfully.';
    } else if (response.statusCode == 400) {
      throw Exception(jsonDecode(response.body)['error'].toString());
    } else {
      throw Exception('Failed to delete data: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred during DELETE request: $e');
  }
}
