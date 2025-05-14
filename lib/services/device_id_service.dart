import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const String _deviceIdKey = 'unique_device_id';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  Future<String> getUniqueDeviceId() async {
    try {
      String? storedId = await _secureStorage.read(key: _deviceIdKey);
      
      if (storedId != null && storedId.isNotEmpty) {
        return storedId;
      }
      
      final uuid = const Uuid().v4();
      
      await _secureStorage.write(key: _deviceIdKey, value: uuid);
      
      debugPrint('Nuevo ID de dispositivo generado y almacenado: $uuid');
      return uuid;
    } catch (e) {
      debugPrint('Error al obtener/generar ID de dispositivo: $e');
      return 'temp_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final deviceData = <String, dynamic>{};
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        
        deviceData['model'] = androidInfo.model;
        deviceData['manufacturer'] = androidInfo.manufacturer;
        deviceData['androidVersion'] = androidInfo.version.release;
        deviceData['sdkInt'] = androidInfo.version.sdkInt;
        deviceData['brand'] = androidInfo.brand;
        deviceData['device'] = androidInfo.device;
        deviceData['hardware'] = androidInfo.hardware;
        deviceData['isPhysicalDevice'] = androidInfo.isPhysicalDevice;
        
        deviceData['androidId'] = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        
        deviceData['model'] = iosInfo.model;
        deviceData['systemName'] = iosInfo.systemName;
        deviceData['systemVersion'] = iosInfo.systemVersion;
        deviceData['name'] = iosInfo.name;
        deviceData['isPhysicalDevice'] = iosInfo.isPhysicalDevice;
        deviceData['identifierForVendor'] = iosInfo.identifierForVendor;
      }
      
      return deviceData;
    } catch (e) {
      debugPrint('Error al obtener información del dispositivo: $e');
      return {'error': e.toString()};
    }
  }
  
  Future<void> clearDeviceId() async {
    try {
      await _secureStorage.delete(key: _deviceIdKey);
      debugPrint('ID de dispositivo eliminado correctamente');
    } catch (e) {
      debugPrint('Error al eliminar ID de dispositivo: $e');
    }
  }
}
