import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> _getHeaders({
    bool requireAuth = true,
  }) async {
    final headers = {'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<http.Response> get(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    final headers = await _getHeaders(requireAuth: requireAuth);
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(url, headers: headers);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async {
    final headers = await _getHeaders(requireAuth: requireAuth);
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async {
    final headers = await _getHeaders(requireAuth: requireAuth);
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(body),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    final headers = await _getHeaders(requireAuth: requireAuth);
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.delete(url, headers: headers);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> saveAuthToken(String token) => _saveToken(token);
  static Future<void> clearAuthToken() => _removeToken();
  static Future<String?> getAuthToken() => _getToken();
}
