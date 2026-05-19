import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ApiClient {
  ApiClient._() {
    _initClient();
  }

  static final ApiClient instance = ApiClient._();

  late http.Client _client;

  static const _configuredBaseUrl = String.fromEnvironment(
    'FLEXIDRIVE_API_BASE_URL',
    defaultValue: '',
  );
  static const _requestTimeout = Duration(seconds: 15);
  static const _connectionTimeout = Duration(seconds: 5);

  /// Cache simple para respuestas GET
  final Map<String, _CachedResponse> _cache = {};
  static const _cacheDuration = Duration(minutes: 2);

  void _initClient() {
    if (kIsWeb) {
      _client = http.Client();
    } else {
      final ioClient = HttpClient()
        ..connectionTimeout = _connectionTimeout
        ..idleTimeout = const Duration(seconds: 30)
        ..maxConnectionsPerHost = 10;
      _client = IOClient(ioClient);
    }
  }

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

  /// Limpia el cache de respuestas
  void clearCache() => _cache.clear();

  Future<List<dynamic>> getList(String path, {bool useCache = true}) async {
    final decoded = await _send('GET', path, useCache: useCache);
    if (decoded is List) return decoded;
    if (decoded is Map) {
      final dynamic results = decoded['results'] ?? decoded['data'] ?? decoded['items'];
      if (results is List) return results;
    }
    return const [];
  }

  Future<Map<String, dynamic>> getMap(String path,
      {bool useCache = true}) async {
    final decoded = await _send('GET', path, useCache: useCache);
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

  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool useCache = false,
  }) async {
    final uri = Uri.parse('$baseUrl/${path.replaceFirst(RegExp(r'^/+'), '')}');
    final cacheKey = '$method:$uri';

    // Verificar cache para GET requests
    if (method == 'GET' && useCache && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (!cached.isExpired) {
        return cached.data;
      }
      _cache.remove(cacheKey);
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip',
      'Connection': 'keep-alive',
      if (body != null) 'Content-Type': 'application/json',
    };

    // Retry logic con backoff exponencial
    const maxRetries = 2;
    var attempt = 0;

    while (true) {
      try {
        final response = await switch (method) {
          'POST' => _client
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(_requestTimeout),
          'PATCH' => _client
              .patch(uri, headers: headers, body: jsonEncode(body))
              .timeout(_requestTimeout),
          'PUT' => _client
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(_requestTimeout),
          'DELETE' =>
            _client.delete(uri, headers: headers).timeout(_requestTimeout),
          _ => _client.get(uri, headers: headers).timeout(_requestTimeout),
        };

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw ApiException(
            'HTTP ${response.statusCode} ${response.reasonPhrase ?? ''}'.trim(),
            response.body,
          );
        }

        if (response.body.trim().isEmpty) return null;
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        // Guardar en cache para GET requests exitosos
        if (method == 'GET' && useCache) {
          _cache[cacheKey] = _CachedResponse(decoded, DateTime.now());
        }

        return decoded;
      } on SocketException catch (e) {
        attempt++;
        if (attempt > maxRetries) {
          throw ApiException(
              'Connection failed after $maxRetries retries', e.toString());
        }
        // Backoff exponencial: 200ms, 400ms
        await Future.delayed(Duration(milliseconds: 200 * attempt));
      }
    }
  }

  /// Cierra el cliente HTTP (libera recursos)
  void dispose() {
    _client.close();
    _cache.clear();
  }

  Map<String, dynamic> _asStringKeyMap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}

/// Clase interna para cache de respuestas
class _CachedResponse {
  _CachedResponse(this.data, this.timestamp);
  final dynamic data;
  final DateTime timestamp;

  bool get isExpired =>
      DateTime.now().difference(timestamp) > ApiClient._cacheDuration;
}

class ApiException implements Exception {
  const ApiException(this.message, this.body);

  final String message;
  final String body;

  @override
  String toString() => '$message: $body';
}
