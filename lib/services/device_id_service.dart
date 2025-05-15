import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const String _deviceIdKey = 'unique_device_id';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
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
