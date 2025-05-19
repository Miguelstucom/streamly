import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userIdKey = 'user_id';

  static Future<void> saveToken(
    String token,
    String tokenType, {
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenTypeKey, tokenType);
    if (userId != null) {
      await prefs.setInt(_userIdKey, userId);
    }
  }

  static Future<Map<String, String?>> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'token_type': prefs.getString(_tokenTypeKey),
      'user_id': prefs.getInt(_userIdKey)?.toString(),
    };
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_userIdKey);
  }

  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }
}
