import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Models/EmployeeModel.dart';
import 'dioClient.dart';

// String url = "${dotenv.env['API_URL']}login/";
String url = 'login/';
final InterceptedClient client = InterceptedClient();

Future<EmployeeModel> login(String userId, String password) async {
  try {
    final uri = Uri.parse('$url?employee_code=$userId&password=$password');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      return EmployeeModel.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login');
    }
  } catch (e, stacktrace) {
    print('Error: $e');
    print('Stacktrace: $stacktrace');
    throw Exception(e);
  }
}
