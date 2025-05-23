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
  /// Endpoint para verificar la versión de la aplicación
  static const String _versionEndpoint = '/app-version';

  /// Nombre del archivo APK para guardar
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
              'latestVersion': 'Nueva versión', // No tenemos el número exacto
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
          // Para Android 9 y anteriores, solicitar permiso de almacenamiento normal
          final status = await Permission.storage.request();
          if (!status.isGranted) return null;
          filePath = '/storage/emulated/0/Download/$_apkFileName';
        }
      } else {
        // En iOS u otras plataformas, usar el directorio de documentos
        final directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$_apkFileName';
      }

      // Guardar el archivo
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      print('Error al guardar el APK: $e');
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
        print('Intentando instalar APK desde: $filePath');
        
        // Verificar y solicitar permiso para instalar paquetes
        final status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          print('Solicitando permiso para instalar paquetes');
          final result = await Permission.requestInstallPackages.request();
          if (!result.isGranted) {
            print('Permiso para instalar paquetes denegado');
            return false;
          }
        }
        
        // Verificar si el archivo existe
        final file = File(filePath);
        if (!await file.exists()) {
          print('El archivo APK no existe en la ruta especificada');
          return false;
        }

        // Usar OpenFile para abrir el APK con el instalador nativo
        print('Abriendo APK con OpenFile: $filePath');
        final result = await OpenFile.open(
          filePath,
          type: 'application/vnd.android.package-archive',
        );
        
        print('Resultado de OpenFile: ${result.message}, ${result.type}');
        return result.type == ResultType.done;
      }
      return false;
    } catch (e) {
      print('Error al instalar APK: $e');
      return false;
    }
  }
}
