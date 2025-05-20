import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Servicio que gestiona la obtención y almacenamiento del identificador único del dispositivo.
/// Genera un UUID v4 la primera vez y lo almacena para usos posteriores.
class DeviceIdService {
  /// Clave para almacenar el ID del dispositivo en el almacenamiento seguro
  static const String _deviceIdKey = 'unique_device_id';
  /// Instancia de almacenamiento seguro para guardar el ID del dispositivo
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// Obtiene el identificador único del dispositivo
  /// Si no existe, genera uno nuevo utilizando UUID v4 y lo almacena
  /// @return [String] ID único del dispositivo o un ID temporal en caso de error
  Future<String> getUniqueDeviceId() async {
    try {
      String? storedId = await _secureStorage.read(key: _deviceIdKey);
      
      if (storedId != null && storedId.isNotEmpty) {
        return storedId;
      }
      
      final uuid = const Uuid().v4();
      
      await _secureStorage.write(key: _deviceIdKey, value: uuid);
      
      return uuid;
    } catch (e) {
      return 'temp_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
