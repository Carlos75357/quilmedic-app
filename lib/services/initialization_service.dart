import 'package:quilmedic/utils/alarm_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitializationService {
  static const String _lastAppStartKey = 'last_app_start';
  static const int _minHoursBetweenUpdates = 6;

  static Future<void> initialize() async {
    await _initializeAlarms();
  }

  static Future<void> _initializeAlarms() async {
    final alarmUtils = AlarmUtils();
    
    if (await _shouldUpdateOnAppStart()) {
      await alarmUtils.forceRefresh();
      await _updateLastAppStartTime();
    } else {
      await alarmUtils.loadAlarmsFromCache();
    }
  }

  static Future<bool> _shouldUpdateOnAppStart() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStart = prefs.getInt(_lastAppStartKey);
    
    if (lastStart == null) {
      return true;
    }
    
    final lastStartTime = DateTime.fromMillisecondsSinceEpoch(lastStart);
    final now = DateTime.now();
    final difference = now.difference(lastStartTime).inHours;
    
    return difference >= _minHoursBetweenUpdates;
  }

  static Future<void> _updateLastAppStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastAppStartKey, DateTime.now().millisecondsSinceEpoch);
  }
}
