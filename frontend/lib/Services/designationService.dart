import 'dart:convert';
import 'package:frontend/Models/Designation.dart';

import 'dioClient.dart';

String url = 'designation/';
final uri = Uri.parse(url);

final InterceptedClient client = InterceptedClient();

Future<List<DesignationModel>> getDesignations() async {
  try {
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<DesignationModel> designations = data.map((des) {
        return DesignationModel.fromJson(des as Map<String, dynamic>);
      }).toList();
      return designations;
    } else {
      throw Exception('Failed to load designations: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<DesignationModel> createDesignation(DesignationModel designation) async {
  try {
    var request = await client.post(uri, body: designation.toJson());

    if (request.statusCode == 201) {
      return DesignationModel.fromJson(
          jsonDecode(request.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to save designation: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<DesignationModel> updateDesignation(
    int id, DesignationModel designation) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = await client.put(uriPut, body: designation.toJson());

    if (request.statusCode == 200) {
      Map<String, dynamic> data =
          jsonDecode(request.body) as Map<String, dynamic>;
      return DesignationModel.fromJson(data);
    } else {
      throw Exception('Failed to save designation: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<String> deleteDesignation(int id) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = await client.delete(uriPut);

    if (request.statusCode == 204) {
      return 'Designation deleted successfuly.';
    } else if (request.statusCode == 400) {
      throw Exception(jsonDecode(request.body)['error_message'].toString());
    } else {
      throw Exception('Failed to delete designation: ${request.reasonPhrase}');
    }
  } catch (e) {
    rethrow;
  }
}

DesignationModel getDesignationByName(
    String name, List<DesignationModel> designations) {
  return designations.firstWhere((designation) => designation.name == name);
}
