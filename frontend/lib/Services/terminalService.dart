import 'dart:convert';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Models/SiteModel.dart';

import '../Utils/location.dart';
import 'dioClient.dart';

final String baseUrl = 'site/';
final InterceptedClient client = InterceptedClient();

Future<List<SiteModel>> getSite() async {
  return _handleGetRequest('site');
}

Future<SiteModel> createSite(SiteModel site) async {
  return _handlePostRequest('site', site.toJson());
}

Future<SiteModel> updateSite(int id, SiteModel site) async {
  return _handlePutRequest('site/$id', site.toJson());
}

Future<String> deleteSite(int id) async {
  return _handleDeleteRequest('site/$id');
}

Future<List<SiteModel>> getSitesByPort(int portId) async {
  return _handleGetRequest('site?port_id=$portId');
}

Future<SiteModel> getSiteByLocation(EmployeeModel employee, int portId,
    double currentLatitude, double currentLongitude) async {
  List<SiteModel> sites = await getSitesByPort(portId);
  return sites.firstWhere(
    (site) {
      double distance = LocationService.calculateDistance(
          site.latitude, site.longitude, currentLatitude, currentLongitude);
      if (!employee.designation!.remote_checkin &&
          distance > site.geoFenceArea) {
        return false;
      }
      return true;
    },
    orElse: () => SiteModel(
        id: 0,
        name: '',
        latitude: 0.00,
        longitude: 0.00,
        port: 0,
        geoFenceArea: 0),
  );
}

Future<List<SiteModel>> _handleGetRequest(String endpoint) async {
  try {
    Uri uri = Uri.parse(endpoint);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SiteModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred during GET request: $e');
  }
}

Future<SiteModel> _handlePostRequest(
    String endpoint, Map<String, dynamic> body) async {
  try {
    Uri uri = Uri.parse(endpoint);
    final response = await client.post(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 201) {
      return SiteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create data: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred during POST request: $e');
  }
}

Future<SiteModel> _handlePutRequest(
    String endpoint, Map<String, dynamic> body) async {
  try {
    Uri uri = Uri.parse(endpoint);
    final response = await client.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return SiteModel.fromJson(jsonDecode(response.body));
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
      return 'Site deleted successfully.';
    } else {
      throw Exception('Failed to delete data: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error occurred during DELETE request: $e');
  }
}
