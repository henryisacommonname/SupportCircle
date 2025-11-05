import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatApiService {
  ChatApiService(this.baseUrl);

  final String baseUrl;

  Future<Map<String, dynamic>> chatJson({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat_json'),
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
