import 'dart:convert';
import 'package:frontend/Models/PortModel.dart';

import 'dioClient.dart';

String url = 'port/';
final uri = Uri.parse(url);

final InterceptedClient client = InterceptedClient();

Future<List<PortModel>> getPort() async {
  try {
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<PortModel> employees = data.map((emp) {
        return PortModel.fromJson(emp as Map<String, dynamic>);
      }).toList();
      return employees;
    } else {
      throw Exception('Failed to load port: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<PortModel> createPort(PortModel port) async {
  try {
    var request = await client.post(uri, body: port.toJson());

    if (request.statusCode == 201) {
      // var responseJson = json.decode(request.body);
      return PortModel.fromJson(
          jsonDecode(request.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to save port: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<PortModel> updatePort(int id, PortModel port) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = await client.put(uriPut, body: port.toJson());

    if (request.statusCode == 200) {
      Map<String, dynamic> data =
          jsonDecode(request.body) as Map<String, dynamic>;
      return PortModel.fromJson(data);
    } else {
      throw Exception('Failed to save port: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<String> deletePort(int id) async {
  try {
    Uri uriPut = Uri.parse('$url?id=$id');
    var request = await client.delete(uriPut);

    if (request.statusCode == 204) {
      return 'Port deleted successfuly.';
    } else if (request.statusCode == 400) {
      throw Exception(jsonDecode(request.body)['error_message'].toString());
    } else {
      throw Exception('Failed to save port: ${request.reasonPhrase}');
    }
  } catch (e) {
    rethrow;
  }
}

PortModel getPortByName(String name, List<PortModel> ports) {
  return ports.firstWhere((port) => port.name == name);
}
