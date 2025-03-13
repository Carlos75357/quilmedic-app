import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quilmedic/data/config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status code: $statusCode)' : ''}';
}

class DataSource {
  final http.Client _client;

  DataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.apiUrl}$endpoint'),
        headers: ApiConfig.headers,
      ).timeout(Duration(milliseconds: ApiConfig.connectionTimeout));

      return _processResponse(response);
    } catch (e) {
      throw ApiException('Error en la solicitud GET: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.apiUrl}$endpoint'),
        headers: ApiConfig.headers,
        body: jsonEncode(data),
      ).timeout(Duration(milliseconds: ApiConfig.connectionTimeout));

      return _processResponse(response);
    } catch (e) {
      throw ApiException('Error en la solicitud POST: ${e.toString()}');
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Error al decodificar la respuesta: ${e.toString()}');
      }
    } else {
      throw ApiException(
        'Error en la respuesta del servidor: ${response.body}',
        response.statusCode,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}