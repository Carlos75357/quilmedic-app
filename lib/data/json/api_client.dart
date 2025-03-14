import 'package:quilmedic/data/json/json_client.dart';
import 'package:quilmedic/data/json/json_rpc.dart';

class ApiClient {
  JsonClient client = JsonClient();

  Future<dynamic> call(
    String endpoint,
    JsonRequest jsonRequest,
  ) async {
    try {
      var response = await client.call(endpoint, jsonRequest);
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> getAll(String endpoint, dynamic params) async {
    try {
      var jsonRequest = JsonRequest({
        'jsonrpc': '2.0',
        'method': 'getAll',
        'params': params ?? {},
      });

      var response = await client.call(endpoint, jsonRequest);
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> update(String endpoint, dynamic values) async {
    Map<String, dynamic> valuesMap = values.toJson();

    var jsonRequest = JsonRequest({
      'jsonrpc': '2.0',
      'method': 'update',
      'params': valuesMap,
    });

    try {
      var response = await client.call(endpoint, jsonRequest);
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
