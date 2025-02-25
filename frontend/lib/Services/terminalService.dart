import 'dart:convert';
import 'package:frontend/Models/EmployeeModel.dart';
import 'package:frontend/Models/SiteModel.dart';

import '../Utils/location.dart';
import 'dioClient.dart';

String url = 'site/';
Uri uri = Uri.parse(url);

final InterceptedClient client = InterceptedClient();

Future<List<SiteModel>> getSite() async {
  try {
    final response = await client.get(uri);

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
    var request = await client.post(uri, body: site.toJson());

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
    var request = await client.put(uriPut, body: site.toJson());

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
    var request = await client.delete(uriPut);

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
    final response = await client.get(uri);

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

Future<SiteModel> getSiteByLocation(EmployeeModel employee, int portId,
    double currentLatitude, double currentLongitude) async {
  List<SiteModel> sites = await getSitesByPort(portId);
  SiteModel site = sites.firstWhere((site) {
    double distance = LocationService.calculateDistance(
        site.latitude, site.longitude, currentLatitude, currentLongitude);
    if (!employee.designation!.remote_checkin && distance > site.geoFenceArea) {
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
          geoFenceArea: 0));
  return site;
}
