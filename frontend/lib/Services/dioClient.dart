import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Utils/constants.dart';

class InterceptedClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  InterceptedClient();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final newUrl = Uri.parse(baseUrl).resolve(request.url.toString());
    final newRequest = _modifyRequest(request, newUrl);

    debugPrint('Request: ${newRequest.method} ${newRequest.url}');
    newRequest.headers
      ..['Accept'] = 'application/json'
      ..['Authorization'] = 'Bearer your_token_here';

    try {
      final response = await _inner.send(newRequest);
      debugPrint('Response: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('Error: $e');
      if (e.toString().contains('Connection timed out')) {
        throw Exception('No internet connection');
      } else {
        rethrow;
      }
    }
  }

  http.BaseRequest _modifyRequest(http.BaseRequest request, Uri newUrl) {
    if (request is http.MultipartRequest) {
      return _createMultipartRequest(request, newUrl);
    } else {
      return http.Request(request.method, newUrl)
        ..headers.addAll(request.headers)
        ..body = request is http.Request ? request.body : '';
    }
  }

  http.MultipartRequest _createMultipartRequest(
      http.MultipartRequest request, Uri newUrl) {
    final multipartRequest = http.MultipartRequest(request.method, newUrl)
      ..headers.addAll(request.headers)
      ..files.addAll(request.files)
      ..fields.addAll(request.fields);
    return multipartRequest;
  }

  @override
  void close() {
    _inner.close();
  }
}
