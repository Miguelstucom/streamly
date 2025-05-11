import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Guardar el token
        await StorageService.saveToken(
          data['access_token'],
          data['token_type'],
        );
        return {
          'success': true,
          'token': data['access_token'],
          'tokenType': data['token_type'],
        };
      } else {
        return {
          'success': false,
          'error': 'Email o contraseña incorrectos',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión',
      };
    }
  }

  Future<bool> isLoggedIn() async {
    return await StorageService.hasToken();
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
  }

  Future<Map<String, String?>> getStoredToken() async {
    return await StorageService.getToken();
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await getStoredToken();
      if (token['token'] == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        // Si el token no es válido, lo eliminamos
        await logout();
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 