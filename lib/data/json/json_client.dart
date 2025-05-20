import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/exceptions/authentication_exceptions.dart';
import 'package:quilmedic/services/navigation_service.dart';
import 'json_rpc.dart';

/// Clase que implementa un cliente para realizar peticiones HTTP utilizando el protocolo JSON-RPC.
/// Se encarga de gestionar las peticiones HTTP, manejar los encabezados de autenticación
/// y procesar las respuestas del servidor.
class JsonClient {
  /// Realiza una llamada HTTP al endpoint especificado con los datos de la petición JSON-RPC.
  /// Selecciona automáticamente el método HTTP adecuado según el tipo de operación.
  /// @param [endpoint] Ruta del endpoint de la API
  /// @param [jsonRequest] Objeto con los datos de la petición JSON-RPC
  /// @return [dynamic] Respuesta procesada de la API
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

        Uri uri = Uri.parse(
          ApiConfig.baseUrl + endpoint,
        ).replace(queryParameters: formattedParams);

        final response = await http.get(uri, headers: headers);

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
        throw AuthenticationException(
          'Sesión expirada. Por favor inicie sesión nuevamente.',
        );
      } else if (e.toString().contains('401') ||
          e.toString().contains('unauthorized') ||
          e.toString().contains('Unauthorized')) {
        throw AuthenticationException(
          'Error de autenticación. Por favor inicie sesión nuevamente.',
        );
      }
      throw Exception(e.toString());
    }
  }

  /// Obtiene los encabezados HTTP necesarios para la petición, incluyendo el token de autenticación.
  /// @return [Map] Mapa con los encabezados HTTP
  Future<Map<String, String>> _getHeaders() async {
    final token = await ApiConfig.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Procesa la respuesta HTTP y maneja los posibles errores.
  /// Si la respuesta es exitosa, decodifica el cuerpo de la respuesta.
  /// Si hay un error de autenticación (401), limpia el token y redirige al login.
  /// @param [response] Respuesta HTTP recibida
  /// @param [endpoint] Endpoint utilizado en la petición
  /// @param [jsonRequest] Petición original enviada
  /// @return [dynamic] Datos decodificados de la respuesta
  Future<dynamic> _handleResponse(http.Response response, String endpoint, JsonRequest jsonRequest) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(decodedBody);
      return responseData;
    } else if (response.statusCode == 401) {
      await ApiConfig.clearToken();

      NavigationService.navigateToLogin();

      throw TokenExpiredException('Token expirado y no se pudo renovar');
    } else {
      throw Exception(response.body);
    }
  }
}
