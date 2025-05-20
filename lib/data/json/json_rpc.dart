/// Clase que representa una petición JSON-RPC 2.0.
/// Encapsula los elementos estándar de una petición JSON-RPC: versión, método y parámetros.
/// Se utiliza para estructurar las peticiones a la API de forma consistente.
class JsonRequest {
  /// Versión del protocolo JSON-RPC, generalmente '2.0'
  var jsonrpc = '';
  /// Método a invocar en el servidor (ej: 'getAll', 'post', 'update')
  var method = '';
  /// Parámetros asociados con la petición
  var params = {};

  /// Constructor que inicializa una petición JSON-RPC a partir de un mapa
  /// @param [map] Mapa con los datos de la petición (jsonrpc, method, params)
  JsonRequest(Map map) {
    jsonrpc = map['jsonrpc'];
    method = map['method'];
    params = map['params'];
  }

  /// Constructor factory para crear una instancia desde un mapa JSON
  /// @param [json] Mapa con los datos en formato JSON
  /// @return [JsonRequest] Nueva instancia de JsonRequest
  factory JsonRequest.fromJson(Map<String, dynamic> json) {
    return JsonRequest(json);
  }

  /// Convierte la instancia actual a un mapa JSON
  /// @return [Map] Mapa con los datos de la petición en formato JSON
  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'method': method,
      'params': params,
    };
  }
}