import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:quilmedic/data/config.dart';

/// Servicio que gestiona la verificación y descarga de actualizaciones de la aplicación.
/// Proporciona métodos para verificar si hay nuevas versiones disponibles y descargar
/// la última versión de la APK.
class AppVersionService {
  static const String _versionEndpoint = '/app-version';

  static const String _apkFileName = 'quilmedic_installer.apk';

  /// Verifica si hay una nueva versión de la aplicación disponible y la descarga si existe
  /// @return [bool] true si hay una actualización y se ha descargado, false en caso contrario
  Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      // Obtener la versión actual de la aplicación
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      // Formatear la versión reemplazando puntos por guiones bajos (1.1.1 -> 1_1_1)
      final String formattedVersion = currentVersion.replaceAll('.', '_');

      // Usar el masterToken directamente para la autenticación
      final String masterToken = ApiConfig.masterToken;

      // Crear la URL para verificar la versión con el formato requerido
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}$_versionEndpoint',
      ).replace(queryParameters: {'v': formattedVersion});

      // Realizar la petición HTTP con el masterToken para autenticación
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $masterToken',
          'Accept': 'application/vnd.android.package-archive ',
        },
      );

      // Si el código es 204, no hay actualización disponible
      if (response.statusCode == 204) {
        return null;
      }

      // Si el código es 200, hay una actualización disponible y se ha devuelto el archivo APK
      if (response.statusCode == 200) {
        // Si hay datos en el cuerpo de la respuesta, es el archivo APK
        if (response.bodyBytes.isNotEmpty) {
          // Guardar la APK y devolver la información de la actualización
          final String? filePath = await _saveApkFile(response.bodyBytes);

          if (filePath != null) {
            return {
              'currentVersion': currentVersion,
              'latestVersion': 'Nueva versión',
              'filePath': filePath,
              'releaseNotes': 'Nueva actualización disponible',
              'forceUpdate': false,
            };
          }
        }
      }

      return null; // No hay actualización disponible o hubo un error
    } catch (e) {
      // Si hay un error, asumimos que no hay actualización disponible
      return null;
    }
  }

  /// Guarda el archivo APK en el almacenamiento del dispositivo
  /// @param [bytes] Bytes del archivo APK
  /// @return [String] Ruta al archivo guardado o null si falla
  Future<String?> _saveApkFile(List<int> bytes) async {
    try {
      String filePath;

      if (Platform.isAndroid) {
        // En Android 10 (API 29) y superior, necesitamos usar diferentes permisos
        if (await _isAndroid10OrHigher()) {
          // Para Android 10+, necesitamos el permiso MANAGE_EXTERNAL_STORAGE o usar el directorio específico de la app
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            // Si no se otorga el permiso, intentar usar el directorio específico de la app
            final directory = await getExternalStorageDirectory();
            if (directory == null) return null;
            filePath = '${directory.path}/$_apkFileName';
          } else {
            // Si se otorga el permiso, usar el directorio de descargas
            filePath = '/storage/emulated/0/Download/$_apkFileName';
          }
        } else {
          final status = await Permission.storage.request();
          if (!status.isGranted) return null;
          filePath = '/storage/emulated/0/Download/$_apkFileName';
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$_apkFileName';
      }

      // Guardar el archivo
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si el dispositivo tiene Android 10 (API 29) o superior
  Future<bool> _isAndroid10OrHigher() async {
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return androidInfo.version.sdkInt >= 29;
    }
    return false;
  }

  /// Instala la APK descargada
  /// @param [filePath] Ruta al archivo APK
  /// @return [bool] true si se inicia la instalación, false en caso contrario
  Future<bool> installApk(String filePath) async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          final result = await Permission.requestInstallPackages.request();
          if (!result.isGranted) {
            return false;
          }
        }
        
        final file = File(filePath);
        if (!await file.exists()) {
          return false;
        }

        final result = await OpenFile.open(
          filePath,
          type: 'application/vnd.android.package-archive',
        );
        
        return result.type == ResultType.done;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
