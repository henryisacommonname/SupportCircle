import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ChatApiExpection implements Exception {
  const ChatApiExpection(
    this.message, {
    this.statusCode,
    this.isWakingup = false,
  });
  final String message;
  final int? statusCode;
  final bool isWakingup;
  @override
  String toString() => 'ChatApiExpection: $message';
}

class ChatApiService {
  ChatApiService(
    String baseUrl, {
    Duration requesttimeout = const Duration(seconds: 10),
  }) : _baseUri = _normalizeBase(baseUrl),
       _timeout = requesttimeout;

  final Uri _baseUri;
  final Duration _timeout;

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
    http.Response response;
    try {
      response = await http
          .post(
            _resolve('chat_json'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'system_prompt': systemPrompt,
              'user_prompt': userPrompt,
            }),
          )
          .timeout(_timeout);
    } on TimeoutException catch (_) {
      throw ChatApiExpection(
        'Please wait for our assistant to wake up.',
        isWakingup: true,
      );
    } on Exception catch (e) {
      throw ChatApiExpection('Network error: $e');
    }

    if (response.statusCode != 200) {
      throw Exception('Serve error: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
