import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:free_dz/services/auth_service.dart';

class ApiHelper {
  static const String baseUrl = 
/*   'http://127.0.0.1:8000/api';
 */     // for lotfi :
        'http://192.168.210.40:8000/api';  
 

  // Generic GET
  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(url, headers: await _getHeaders());
      return _processResponse(response);
    } catch (e) {
      throw Exception('GET Error: $e');
    }
  }

  // Generic POST
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {

    debugPrint("endpoint: $endpoint");
    debugPrint("body: $body");
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint(url.toString());

    try {
      final response = await http.post(url,
          headers: await _getHeaders(), body: json.encode(body));


      return _processResponse(response);
    } catch (e) {
      throw Exception('POST Error: $e');
    }
  }

  // Generic PUT
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.put(url,
          headers: await _getHeaders(), body: json.encode(body));
      return _processResponse(response);
    } catch (e) {
      throw Exception('PUT Error: $e');
    }
  }

  // Generic DELETE
  static Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.delete(url, headers: await _getHeaders());
      return _processResponse(response);
    } catch (e) {
      throw Exception('DELETE Error: $e');
    }
  }

  static Future<Map<String, dynamic>> putMultipart(
    String endpoint,
    Map<String, String> fields, {
    String? filePath,
    String? fileFieldName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final token = await AuthService.getToken();

      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields.addAll(fields);

      // Add file if provided
      if (filePath != null && fileFieldName != null) {
        final file = await http.MultipartFile.fromPath(
          fileFieldName,
          filePath,
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        final errors = errorData['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final firstError = errors.values.first;
          throw Exception(firstError is List ? firstError.first : firstError);
        }
        throw Exception(errorData['message'] ?? 'Validation error');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update data');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An error occurred: ${e.toString()}');
    }
  }


  // ===== Helper methods =====

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken(); // get auth token if exists
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _processResponse(http.Response response) {
  final decoded = json.decode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    debugPrint('Response Data: $decoded');
    return decoded;
  
    } else if (response.statusCode == 401) {
      AuthService.logout();
      throw Exception('Unauthorized');
    } else {
      throw Exception(
          'API Error ${response.statusCode}: ${response.body}');
    }
  }
}
