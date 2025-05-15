import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamly/config/api_config.dart';
import 'package:streamly/models/user.dart';
import 'package:streamly/services/storage_service.dart';

class AuthService {
  final String _baseUrl = ApiConfig.baseUrl;
  User? _currentUser;
  bool _isInitialized = false;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    final token = await StorageService.getToken();
    if (token['token'] != null) {
      try {
        _currentUser = await getCurrentUser();
      } catch (e) {
        await StorageService.deleteToken();
      }
    }
    _isInitialized = true;
  }

  Future<void> register({
    required String username,
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required int age,
    required String occupation,
    required List<int> preferredGenres,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'password': password,
          'age': age,
          'occupation': occupation,
          'preferred_genres': preferredGenres,
        }),
      );

      if (response.statusCode == 201) {
        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await StorageService.saveToken(
          data['access_token'],
          data['token_type'],
        );

        // Obtener información del usuario después del login
        _currentUser = await getCurrentUser();

        return {
          'success': true,
          'token': data['access_token'],
          'tokenType': data['token_type'],
        };
      } else {
        return {'success': false, 'error': 'Email o contraseña incorrectos'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión'};
    }
  }

  Future<bool> isLoggedIn() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _currentUser != null;
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
    _currentUser = null;
  }

  Future<Map<String, String?>> getStoredToken() async {
    return await StorageService.getToken();
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await getStoredToken();
      if (token['token'] == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else if (response.statusCode == 401) {
        await logout();
        return null;
      }
      return null;
    } catch (e) {
      await logout();
      return null;
    }
  }

  User? get currentUser => _currentUser;
}
