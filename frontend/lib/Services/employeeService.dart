import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../Models/EmployeeModel.dart';
import 'package:http_parser/http_parser.dart';

import '../Utility.dart';

String url = '${baseUrl}employee/';
Uri uri = Uri.parse(url);

Future<List<EmployeeModel>> getEmployees() async {
  try {
    final response =
        await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<EmployeeModel> employees = data.map((emp) {
        return EmployeeModel.fromJson(emp as Map<String, dynamic>);
      }).toList();
      return employees;
    } else {
      throw Exception('Failed to load employees: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<bool> createEmployee(EmployeeModel employee, File file) async {
  try {
    var request = http.MultipartRequest('POST', uri);

    employee.toJson().forEach((key, value) {
      if (key == 'designation') {
        request.fields[key] = value['id'].toString();
      } else {
        request.fields[key] = value.toString();
      }
    });

    final mimeTypeData =
        lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])?.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_image',
        file.path,
        contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
      ),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      // var responseData = await response.stream.bytesToString();
      // var responseJson = json.decode(responseData);
      return true;
    } else {
      throw Exception('Failed to save employees: ${response.reasonPhrase}');
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    throw Exception('Error occurred: $e');
  }
}

Future<bool> updateEmployee(int id, EmployeeModel employee, File file) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = http.MultipartRequest('PUT', uriPut);

    employee.toJson().forEach((key, value) {
      if (key == 'designation') {
        request.fields[key] = value['id'].toString();
      } else {
        request.fields[key] = value.toString();
      }
    });

    if (await file.exists()) {
      final mimeTypeData =
          lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])?.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          file.path,
          contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
        ),
      );

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // var responseData = await response.stream.bytesToString();
        // var responseJson = json.decode(responseData);
        return true;
      } else {
        throw Exception('Failed to save employees: ${response.reasonPhrase}');
      }
    } else {
      final respImage = await http.get(Uri.parse(baseImageUrl + file.path));
      String filename = file.path.split('/').last;

      if (respImage.statusCode == 200) {
        Uint8List bytes = respImage.bodyBytes;
        http.MultipartFile fl = http.MultipartFile.fromBytes(
            'profile_image', bytes,
            filename: filename);
        request.files.add(fl);
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          return true;
        } else {
          throw Exception('Failed to save employees: ${response.reasonPhrase}');
        }
      } else {
        throw Exception('Failed to save employees: ${respImage.reasonPhrase}');
      }
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<String> deleteEmployee(int id) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = await http.delete(uriPut);

    if (request.statusCode == 204) {
      return 'Employee deleted successfuly.';
    } else {
      throw Exception('Failed to delete Employee: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

String generateEmployeeCode(String prefix, List<EmployeeModel> employees) {
  if (employees.isEmpty) return '${prefix}_00000001';
  EmployeeModel emp = employees
      .reduce((value, element) => value.id > element.id ? value : element);

  int maxId = emp.id + 1;
  return '${prefix}_${maxId.toString().padLeft(8, '0')}';
}
