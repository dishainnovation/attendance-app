import 'dart:convert';
import 'package:frontend/Models/Designation.dart';
import 'dioClient.dart';

final String url = 'designation/';
final Uri uri = Uri.parse(url);
final InterceptedClient client = InterceptedClient();

Future<List<DesignationModel>> getDesignations() async {
  try {
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((des) => DesignationModel.fromJson(des)).toList();
    } else {
      throw Exception('Failed to load designations: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<DesignationModel> createDesignation(DesignationModel designation) async {
  try {
    final response = await client.post(uri, body: designation.toJson());

    if (response.statusCode == 201) {
      return DesignationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save designation: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<DesignationModel> updateDesignation(
    int id, DesignationModel designation) async {
  try {
    final Uri uriPut = Uri.parse('$url?id=$id');
    final response = await client.put(uriPut, body: designation.toJson());

    if (response.statusCode == 200) {
      return DesignationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save designation: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<String> deleteDesignation(int id) async {
  try {
    final Uri uriDelete = Uri.parse('$url?id=$id');
    final response = await client.delete(uriDelete);

    if (response.statusCode == 204) {
      return 'Designation deleted successfully.';
    } else if (response.statusCode == 400) {
      throw Exception(jsonDecode(response.body)['error_message'].toString());
    } else {
      throw Exception('Failed to delete designation: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

DesignationModel getDesignationByName(
    String name, List<DesignationModel> designations) {
  return designations.firstWhere((designation) => designation.name == name);
}
