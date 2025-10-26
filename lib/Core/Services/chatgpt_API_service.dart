import 'dart:convert';
import "package:http/http.dart" as http;

class Chat_API {
  String baseURL =
      "https://a23e4be5-1075-4548-baf7-22e80ab91722-00-f46fp7e8sg7i.worf.replit.dev/";
  Chat_API(this.baseURL);
  Future<Map<String, dynamic>> chat_json({
    required String System_Prompt,
    required String User_Prompt,
  }) async {
    final response = await http.post(
      Uri.parse("$baseURL/chat_json"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_prompt': System_Prompt,
        'user_prompt': User_Prompt,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Serve error: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
