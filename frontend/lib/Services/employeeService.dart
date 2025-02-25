import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../Models/EmployeeModel.dart';
import 'package:http_parser/http_parser.dart';

import '../Utils/constants.dart';
import 'dioClient.dart';

final String url = 'employee/';
final Uri uri = Uri.parse(url);
final InterceptedClient client = InterceptedClient();

Future<List<EmployeeModel>> getEmployees() async {
  try {
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((emp) => EmployeeModel.fromJson(emp)).toList();
    } else {
      throw Exception('Failed to load employees: ${response.reasonPhrase}');
    }
  } catch (e) {
    rethrow;
  }
}

Future<bool> createEmployee(EmployeeModel employee, File file) async {
  try {
    var request = http.MultipartRequest('POST', uri);
    _addFieldsToRequest(request, employee);

    await _addFileToRequest(request, file);

    return await _handleRequest(request, 201, 'Failed to save employees');
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    throw Exception('Error occurred: $e');
  }
}

Future<bool> updateEmployee(int id, EmployeeModel employee, File file) async {
  try {
    final Uri uriPut = Uri.parse('$url?id=$id');
    var request = http.MultipartRequest('PUT', uriPut);
    _addFieldsToRequest(request, employee);

    if (await file.exists()) {
      await _addFileToRequest(request, file);
    } else {
      await _addFileFromUrl(request, file);
    }

    return await _handleRequest(request, 200, 'Failed to save employees');
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<String> deleteEmployee(int id) async {
  try {
    final Uri uriDelete = Uri.parse('$url?id=$id');
    final response = await client.delete(uriDelete);

    if (response.statusCode == 204) {
      return 'Employee deleted successfully.';
    } else if (response.statusCode == 400) {
      throw Exception(jsonDecode(response.body)['error_message'].toString());
    } else {
      throw Exception('Failed to delete Employee: ${response.reasonPhrase}');
    }
  } catch (e) {
    rethrow;
  }
}

String generateEmployeeCode(String prefix, List<EmployeeModel> employees) {
  if (employees.isEmpty) return '${prefix}_00000001';
  final EmployeeModel emp = employees
      .reduce((value, element) => value.id > element.id ? value : element);

  final int maxId = emp.id + 1;
  return '${prefix}_${maxId.toString().padLeft(8, '0')}';
}

Future<List<EmployeeModel>> getEmployeesByPort(int portId) async {
  try {
    final Uri uriPort = Uri.parse('$url?port_id=$portId');
    final response = await client.get(uriPort);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((emp) => EmployeeModel.fromJson(emp)).toList();
    } else {
      throw Exception('Failed to load employees: ${response.reasonPhrase}');
    }
  } catch (e) {
    rethrow;
  }
}

void _addFieldsToRequest(
    http.MultipartRequest request, EmployeeModel employee) {
  employee.toJson().forEach((key, value) {
    request.fields[key] =
        key == 'designation' ? value['id'].toString() : value.toString();
  });
}

Future<void> _addFileToRequest(http.MultipartRequest request, File file) async {
  final mimeTypeData =
      lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])?.split('/');
  request.files.add(
    await http.MultipartFile.fromPath(
      'profile_image',
      file.path,
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
    ),
  );
}

Future<void> _addFileFromUrl(http.MultipartRequest request, File file) async {
  final respImage = await http.get(Uri.parse(baseImageUrl + file.path));
  final String filename = file.path.split('/').last;

  if (respImage.statusCode == 200) {
    final Uint8List bytes = respImage.bodyBytes;
    final http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      'profile_image',
      bytes,
      filename: filename,
    );
    request.files.add(multipartFile);
  } else {
    throw Exception('Failed to fetch image: ${respImage.reasonPhrase}');
  }
}

Future<bool> _handleRequest(http.MultipartRequest request,
    int expectedStatusCode, String errorMessage) async {
  final http.StreamedResponse response = await client.send(request);

  if (response.statusCode == expectedStatusCode) {
    return true;
  } else {
    throw Exception('$errorMessage: ${response.reasonPhrase}');
  }
}
