import 'package:quilmedic/data/json/json_client.dart';
import 'package:quilmedic/data/json/json_rpc.dart';

/// Clase que proporciona métodos para realizar peticiones a la API.
/// Actúa como una capa de abstracción para las operaciones CRUD básicas
/// utilizando el protocolo JSON-RPC.
class ApiClient {
  /// Cliente JSON utilizado para realizar las peticiones HTTP
  JsonClient client = JsonClient();

  /// Método base para realizar llamadas a la API
  /// @param endpoint Ruta del endpoint de la API
  /// @param jsonRequest Objeto con los datos de la petición JSON-RPC
  /// @return Respuesta de la API
  Future<dynamic> call(String endpoint, JsonRequest jsonRequest) async {
    try {
      var response = await client.call(endpoint, jsonRequest);
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Obtiene todos los registros de un endpoint específico
  /// @param endpoint Ruta del endpoint de la API
  /// @param params Parámetros opcionales para filtrar la consulta
  /// @return Datos obtenidos de la API
  Future<dynamic> getAll(String endpoint, dynamic params) async {
    try {
      var jsonRequest = JsonRequest({
        'jsonrpc': '2.0',
        'method': 'getAll',
        'params': params ?? {},
      });

      var response = await call(endpoint, jsonRequest);

      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }

      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Crea un nuevo registro en el endpoint especificado
  /// @param endpoint Ruta del endpoint de la API
  /// @param values Datos a enviar para crear el registro
  /// @return Respuesta de la API con los datos del registro creado
  Future<dynamic> post(String endpoint, dynamic values) async {
    try {
      var jsonRequest = JsonRequest({
        'jsonrpc': '2.0',
        'method': 'post',
        'params': values,
      });

      var response = await client.call(endpoint, jsonRequest);

      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }

      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Actualiza un registro existente en el endpoint especificado
  /// @param endpoint Ruta del endpoint de la API
  /// @param values Datos a enviar para actualizar el registro
  /// @return Respuesta de la API
  Future<dynamic> update(String endpoint, dynamic values) async {
    try {
      var jsonRequest = JsonRequest({
        'jsonrpc': '2.0',
        'method': 'update',
        'params': values,
      });

      var response = await client.call(endpoint, jsonRequest);
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Actualiza parcialmente un registro existente en el endpoint especificado
  /// @param endpoint Ruta del endpoint de la API
  /// @param values Datos a enviar para actualizar parcialmente el registro
  /// @return Respuesta de la API
  Future<dynamic> patch(String endpoint, dynamic values) async {
    try {
      var jsonRequest = JsonRequest({
        'jsonrpc': '2.0',
        'method': 'patch',
        'params': values,
      });

      var response = await client.call(endpoint, jsonRequest);
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
