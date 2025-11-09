import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatApiService {
  ChatApiService(String baseUrl) : _baseUri = _normalizeBase(baseUrl);

  final Uri _baseUri;

  static Uri _normalizeBase(String url) {
    final trimmed = url.trim();
    final normalized = trimmed.endsWith('/') ? trimmed : '$trimmed/';
    return Uri.parse(normalized);
  }

  Uri _resolve(String path) => _baseUri.resolve(path);

  Future<Map<String, dynamic>> chatJson({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final response = await http.post(
      _resolve('chat_json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_prompt': systemPrompt,
        'user_prompt': userPrompt,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Serve error: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
