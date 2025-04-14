import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quilmedic/data/config.dart';

class ConnectivityService {
  static Future<bool> hayConexionInternet() async {
    try {
      if (kIsWeb) {
        try {
          final response = await http
              .get(
                Uri.parse(
                  '${ApiConfig.baseUrl}${ApiConfig.hospitalesEndpoint}',
                ),
                headers: ApiConfig.headers,
              )
              .timeout(const Duration(seconds: 3));

          return response.statusCode >= 200 && response.statusCode < 500;
        } catch (e) {
          return false;
        }
      } else {
        try {
          final response = await http
              .get(
                Uri.parse(
                  '${ApiConfig.baseUrl}${ApiConfig.hospitalesEndpoint}',
                ),
                headers: ApiConfig.headers,
              )
              .timeout(const Duration(seconds: 3));

          if (response.statusCode >= 200 && response.statusCode < 500) {
            return true;
          }

          return true;
        } catch (e) {
          try {
            final response = await http
                .get(
                  Uri.parse(
                    '${ApiConfig.baseUrl}${ApiConfig.productosEndpoint}',
                  ),
                  headers: ApiConfig.headers,
                )
                .timeout(const Duration(seconds: 3));

            return response.statusCode >= 200;
          } catch (e) {
            return false;
          }
        }
      }
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }
}
