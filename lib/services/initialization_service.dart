import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que gestiona la inicialización de la aplicación.
/// Controla cuándo se deben realizar actualizaciones basadas en el tiempo
/// transcurrido desde el último inicio de la aplicación.
class InitializationService {
  /// Clave para almacenar la marca de tiempo del último inicio de la aplicación
  static const String _lastAppStartKey = 'last_app_start';
  /// Número mínimo de horas entre actualizaciones
  static const int _minHoursBetweenUpdates = 6;

  /// Inicializa la aplicación y determina si se debe realizar una actualización
  /// basada en el tiempo transcurrido desde el último inicio
  static Future<void> initialize() async {
    await SharedPreferences.getInstance();
    
    final shouldUpdate = await _shouldUpdateOnAppStart();
    if (shouldUpdate) {
      await _updateLastAppStartTime();
    }
    
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Determina si se debe realizar una actualización al iniciar la aplicación
  /// basado en el tiempo transcurrido desde el último inicio
  /// @return true si han pasado más de _minHoursBetweenUpdates horas desde el último inicio
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

  /// Actualiza la marca de tiempo del último inicio de la aplicación
  /// con la hora actual
  static Future<void> _updateLastAppStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastAppStartKey, DateTime.now().millisecondsSinceEpoch);
  }
}
