import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const _configuredBaseUrl = String.fromEnvironment(
    'FLEXIDRIVE_API_BASE_URL',
    defaultValue: '',
  );
  static const _requestTimeout = Duration(seconds: 8);

  String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    final host = Uri.base.host;
    if (host.isNotEmpty && (host == 'localhost' || host == '127.0.0.1')) {
      return 'http://$host:8000/api';
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  Future<List<dynamic>> getList(String path) async {
    final decoded = await _send('GET', path);
    return decoded is List ? decoded : const [];
  }

  Future<Map<String, dynamic>> getMap(String path) async {
    final decoded = await _send('GET', path);
    return _asStringKeyMap(decoded);
  }

  Future<Map<String, dynamic>> postMap(
    String path,
    Map<String, dynamic> body,
  ) async {
    final decoded = await _send('POST', path, body: body);
    return _asStringKeyMap(decoded);
  }

  Future<Map<String, dynamic>> patchMap(
    String path,
    Map<String, dynamic> body,
  ) async {
    final decoded = await _send('PATCH', path, body: body);
    return _asStringKeyMap(decoded);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl/${path.replaceFirst(RegExp(r'^/+'), '')}');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    final response = await switch (method) {
      'POST' => http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(_requestTimeout),
      'PATCH' => http
          .patch(uri, headers: headers, body: jsonEncode(body))
          .timeout(_requestTimeout),
      _ => http.get(uri, headers: headers).timeout(_requestTimeout),
    };

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'HTTP ${response.statusCode} ${response.reasonPhrase ?? ''}'.trim(),
        response.body,
      );
    }

    if (response.body.trim().isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Map<String, dynamic> _asStringKeyMap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}

class ApiException implements Exception {
  const ApiException(this.message, this.body);

  final String message;
  final String body;

  @override
  String toString() => '$message: $body';
}
