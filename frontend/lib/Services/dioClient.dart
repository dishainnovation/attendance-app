import 'package:http/http.dart' as http;

import '../Utils/constants.dart';

class InterceptedClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  InterceptedClient();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Add base URL to the request
    final newUrl = Uri.parse(baseUrl).resolve(request.url.toString());
    http.BaseRequest newRequest;

    // Handle MultipartRequest separately
    if (request is http.MultipartRequest) {
      final multipartRequest = http.MultipartRequest(request.method, newUrl);
      multipartRequest.headers.addAll(request.headers);
      multipartRequest.files.addAll(request.files);
      multipartRequest.fields.addAll(request.fields);
      newRequest = multipartRequest;
    } else {
      newRequest = http.Request(request.method, newUrl)
        ..headers.addAll(request.headers)
        ..body = request is http.Request ? request.body : '';
    }

    // Add request interceptor logic here
    print('Request: ${newRequest.method} ${newRequest.url}');
    newRequest.headers['Accept'] = 'application/json';
    newRequest.headers['Authorization'] = 'Bearer your_token_here';

    try {
      final response = await _inner.send(newRequest);

      // Add response interceptor logic here
      print('Response: ${response.statusCode}');

      return response;
    } catch (e) {
      // Handle errors
      print('Error: $e');
      if (e.toString().contains('Connection timed out')) {
        throw Exception('No internet connection');
      } else {
        rethrow;
      }
    }
  }

  @override
  void close() {
    _inner.close();
  }
}
