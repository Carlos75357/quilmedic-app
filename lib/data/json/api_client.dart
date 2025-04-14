import 'package:quilmedic/data/json/json_client.dart';
import 'package:quilmedic/data/json/json_rpc.dart';

class ApiClient {
  JsonClient client = JsonClient();

  Future<dynamic> call(String endpoint, JsonRequest jsonRequest) async {
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

      var response = await call(endpoint, jsonRequest);

      if (response is Map && response.containsKey('data')) {
        return response['data'];
      }

      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

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
