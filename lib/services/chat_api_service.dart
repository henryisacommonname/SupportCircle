import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isWakingUp;

  const ChatApiException(
    this.message, {
    this.statusCode,
    this.isWakingUp = false,
  });

  @override
  String toString() => 'ChatApiException: $message';
}

class ChatApiService {
  final Uri _baseUri;
  final Duration _timeout;

  ChatApiService(
    String baseUrl, {
    Duration requestTimeout = const Duration(seconds: 10),
  })  : _baseUri = _normalizeBase(baseUrl),
        _timeout = requestTimeout;

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
      throw ChatApiException(
        'Please wait for our assistant to wake up.',
        isWakingUp: true,
      );
    } on Exception catch (e) {
      throw ChatApiException('Network error: $e');
    }

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
