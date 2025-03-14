import 'dart:convert';
import 'json_rpc.dart';
import 'package:http/http.dart' as http;
import 'package:quilmedic/data/config.dart';

class JsonClient {
  Future<dynamic> call(String endpoint, JsonRequest jsonRequest) async {
    try {
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
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
