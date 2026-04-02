import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/inspection_model.dart';

class ApiService {
  // Ganti dengan URL server
  static const String baseUrl = 'http://your-server.com/api';

  // SharedPreferences singleton 
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  //  Token helpers 
  static Future<String?> getToken() async {
    final prefs = await _storage;
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await _storage;
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await _storage;
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Auth 
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: await _headers(auth: false),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        await saveToken(data['token']);
        final prefs = await _storage;
        await prefs.setString('user_data', jsonEncode(data['user']));
      }
      return data;
    } catch (e) {
      return {'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: await _headers(auth: false),
            body: jsonEncode(
                {'name': name, 'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['token'] != null) {
        await saveToken(data['token']);
        final prefs = await _storage;
        await prefs.setString('user_data', jsonEncode(data['user']));
      }
      return data;
    } catch (e) {
      return {'message': 'Koneksi gagal: $e'};
    }
  }

  static Future<UserModel?> getProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/profile'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data['user'] ?? data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/auth/profile'),
            headers: await _headers(),
            body: jsonEncode(updates),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await _storage;
        await prefs.setString('user_data', jsonEncode(data['user'] ?? updates));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Inspections 
  static Future<List<InspectionModel>> getInspections() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/inspections'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] ?? data;
        return (list as List)
            .map((e) => InspectionModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveInspection(InspectionModel inspection) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/inspections'),
            headers: await _headers(),
            body: jsonEncode(inspection.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteInspection(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/inspections/$id'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Local user cache 
  static Future<UserModel?> getCachedUser() async {
    try {
      final prefs = await _storage;
      final raw = prefs.getString('user_data');
      if (raw != null) return UserModel.fromJson(jsonDecode(raw));
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}