import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Models/EmployeeModel.dart';

// String url = "${dotenv.env['API_URL']}login/";
String url = 'http://192.168.0.101:8000/login';

Future<Employeemodel> login(String userId, String password) async {
  try {
    final uri = Uri.parse('$url?user_id=$userId&password=$password');
    final response =
        await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      return Employeemodel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to login');
    }
  } catch (e, stacktrace) {
    print('Error: $e');
    print('Stacktrace: $stacktrace');
    throw Exception(e);
  }
}
