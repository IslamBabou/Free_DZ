import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:free_dz/services/auth_service.dart';

class ApiHelper {
  static const String baseUrl = 'http://192.168.5.40:8000/api';

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
    final url = Uri.parse('$baseUrl$endpoint');

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

  // ===== Helper methods =====

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken(); // get auth token if exists
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
        print("befor");
    final test_data= json.decode(response.body);
    print('Response Data: $test_data');
    debugPrint("after");

      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      AuthService.logout();
      throw Exception('Unauthorized');
    } else {
      throw Exception(
          'API Error ${response.statusCode}: ${response.body}');
    }
  }
}
