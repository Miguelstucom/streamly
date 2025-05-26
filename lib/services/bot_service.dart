import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class BotService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  //static const String baseUrl = 'https://previously-smooth-oriole.ngrok-free.app';

  Future<String> chatWithBot(String query) async {
    try {
      final token = await StorageService.getToken();
      if (token['token'] == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token['token']}',
        },
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else if (response.statusCode == 401) {
        await StorageService.deleteToken();
        throw Exception('Unauthorized');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error processing chat request');
      }
    } catch (e) {
      throw Exception('Failed to chat with bot: $e');
    }
  }
}
