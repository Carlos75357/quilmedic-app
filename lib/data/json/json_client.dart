import 'dart:convert';
import 'json_rpc.dart';
import 'package:http/http.dart' as http;
import 'package:quilmedic/data/config.dart';

class JsonClient {
  Future<dynamic> call(String endpoint, JsonRequest jsonRequest) async {
    try {
      if (jsonRequest.method == 'create') {
        final response = await http.post(
          Uri.parse(ApiConfig.baseUrl + endpoint),
          headers: ApiConfig.headers,
          body: jsonEncode(jsonRequest.toJson()),
        );
        if (response.statusCode == 200) {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final responseData = jsonDecode(decodedBody);
          return responseData;
        } else {
          throw Exception(response.body);
        }
      } else if (jsonRequest.method.contains('get')) {
        final response = await http.get(
          Uri.parse(ApiConfig.baseUrl + endpoint),
          headers: ApiConfig.headers,
        );

        if (response.statusCode == 200) {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final responseData = jsonDecode(decodedBody);
          return responseData;
        } else {
          throw Exception(response.body);
        }
      } else if (jsonRequest.method == 'update') {
        final response = await http.put(
          Uri.parse(ApiConfig.baseUrl + endpoint),
          headers: ApiConfig.headers,
          body: jsonEncode(jsonRequest.params),
        );
        if (response.statusCode == 200) {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final responseData = jsonDecode(decodedBody);
          return responseData;
        } else {
          throw Exception(response.body);
        }
      } else if (jsonRequest.method == 'patch') {
        final response = await http.patch(
          Uri.parse(ApiConfig.baseUrl + endpoint),
          headers: ApiConfig.headers,
          body: jsonEncode(jsonRequest.params),
        );
        if (response.statusCode == 200) {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final responseData = jsonDecode(decodedBody);
          return responseData;
        } else {
          throw Exception(response.body);
        }
      } else {
        // Para métodos personalizados, usamos POST
        final response = await http.post(
          Uri.parse(ApiConfig.baseUrl + endpoint),
          headers: ApiConfig.headers,
          body: jsonEncode(jsonRequest.toJson()),
        );
        if (response.statusCode == 200) {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final responseData = jsonDecode(decodedBody);
          return responseData;
        } else {
          throw Exception(response.body);
        }
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
