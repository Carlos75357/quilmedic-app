import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static Future<bool> hayConexionInternet() async {
    try {
      if (kIsWeb) {
        try {
          return true;
        } catch (e) {
          return false;
        }
      } else {
        final List<InternetAddress> result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
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
