import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/Models/SiteModel.dart';

import '../Utility.dart';

String url = '${baseUrl}site/';
Uri uri = Uri.parse(url);

Future<List<SiteModel>> getSite() async {
  try {
    final response =
        await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<SiteModel> employees = data.map((emp) {
        return SiteModel.fromJson(emp as Map<String, dynamic>);
      }).toList();
      return employees;
    } else {
      throw Exception('Failed to load site: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<SiteModel> createSite(SiteModel site) async {
  try {
    var request = await http.post(uri, body: site.toJson());

    if (request.statusCode == 201) {
      return SiteModel.fromJson(
          jsonDecode(request.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to save site: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<SiteModel> updateSite(int id, SiteModel site) async {
  try {
    Uri uriPut = Uri.parse('$url$id/');
    var request = await http.put(uriPut, body: site.toJson());

    if (request.statusCode == 200) {
      Map<String, dynamic> data =
          jsonDecode(request.body) as Map<String, dynamic>;
      return SiteModel.fromJson(data);
    } else {
      throw Exception('Failed to save site: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<String> deleteSite(int id) async {
  try {
    Uri uriPut = Uri.parse('$url$id/');
    var request = await http.delete(uriPut);

    if (request.statusCode == 204) {
      return 'Site deleted successfuly.';
    } else {
      throw Exception('Failed to save site: ${request.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}

Future<List<SiteModel>> getSitesByPort(int portId) async {
  try {
    uri = Uri.parse('$url?port_id=$portId');
    final response =
        await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<SiteModel> employees = data.map((emp) {
        return SiteModel.fromJson(emp as Map<String, dynamic>);
      }).toList();
      return employees;
    } else {
      throw Exception('Failed to load site: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred: $e');
  }
}
