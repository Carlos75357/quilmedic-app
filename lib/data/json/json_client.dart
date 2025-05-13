import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/services/navigation_service.dart';
import 'json_rpc.dart';

// Excepciones personalizadas para manejo de errores de autenticación
class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException(this.message);
  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  @override
  String toString() => message;
}

class JsonClient {
  Future<dynamic> call(String endpoint, JsonRequest jsonRequest) async {
    try {
      final headers = await _getHeaders();
      
      if (jsonRequest.method == 'create') {
        final response = await http.post(
          Uri.parse(ApiConfig.baseUrl + endpoint),
          headers: headers,
          body: jsonEncode(jsonRequest.toJson()),
        );
        return _handleResponse(response, endpoint, jsonRequest);
      } else if (jsonRequest.method.contains('get')) {
        Map<String, String> formattedParams = jsonRequest.params.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.join(','));
          } else {
            return MapEntry(key, value.toString());
          }
        });

        Uri uri = Uri.parse(ApiConfig.baseUrl + endpoint).replace(queryParameters: formattedParams);
        
        final response = await http.get(
          uri,
          headers: headers,
        );

        return _handleResponse(response, endpoint, jsonRequest);
      } else if (jsonRequest.method == 'update') {
        final response = await http.put(
          Uri.parse(ApiConfig.baseUrl + endpoint),
          headers: headers,
          body: jsonEncode(jsonRequest.params),
        );
        return _handleResponse(response, endpoint, jsonRequest);
      } else if (jsonRequest.method == 'patch') {
        final response = await http.patch(
          Uri.parse(ApiConfig.baseUrl + endpoint),
          headers: headers,
          body: jsonEncode(jsonRequest.params),
        );
        return _handleResponse(response, endpoint, jsonRequest);
      } else {
        if (endpoint.contains('login')) {
          headers.clear();
          headers.addAll(ApiConfig.headers);
        }
        final response = await http.post(
          Uri.parse(ApiConfig.baseUrl + endpoint),
          headers: headers,
          body: jsonEncode(jsonRequest.params),
        );
        return _handleResponse(response, endpoint, jsonRequest);
      }
    } catch (e) {
      if (e is TokenExpiredException) {
        throw AuthenticationException('Sesión expirada. Por favor inicie sesión nuevamente.');
      } else if (e.toString().contains('401') || 
                e.toString().contains('unauthorized') || 
                e.toString().contains('Unauthorized')) {
        throw AuthenticationException('Error de autenticación. Por favor inicie sesión nuevamente.');
      }
      throw Exception(e.toString());
    }
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await ApiConfig.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  Future<dynamic> _handleResponse(http.Response response, String endpoint, JsonRequest jsonRequest) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedBody);
      return responseData;
    } else if (response.statusCode == 401) {
      debugPrint('Token expirado, intentando renovar...');
      final bool tokenRenewed = await ApiConfig.renewToken();
      
      if (tokenRenewed) {
        return await call(endpoint, jsonRequest);
      } else {
        // Limpiar datos y navegar al login
        await ApiConfig.clearToken();
        
        // Usar NavigationService para navegar al login
        NavigationService.navigateToLogin();
        
        throw TokenExpiredException('Token expirado y no se pudo renovar');
      }
    } else {
      throw Exception(response.body);
    }
  }
}
