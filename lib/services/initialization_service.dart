import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quilmedic/utils/alarm_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitializationService {
  static const String _lastAppStartKey = 'last_app_start';
  static const int _minHoursBetweenUpdates = 6;

  static Future<void> initialize() async {
    // Inicializar las alarmas en un Future separado para no bloquear la UI
    // unawaited(_initializeAlarmsWithErrorHandling());
  }

  // static Future<void> _initializeAlarmsWithErrorHandling() async {
  //   try {
  //     final alarmUtils = AlarmUtils();

  //     if (await _shouldUpdateOnAppStart()) {
  //       try {
  //         await alarmUtils.forceRefresh();
  //         await _updateLastAppStartTime();
  //       } catch (e) {
  //         debugPrint('Error al actualizar alarmas: $e');
  //         // Si hay un error al actualizar, intentar cargar desde caché
  //         await alarmUtils.loadAlarmsFromCache();
  //       }
  //     } else {
  //       await alarmUtils.loadAlarmsFromCache();
  //     }
  //   } catch (e) {
  //     // Capturar cualquier error para evitar que la aplicación se bloquee
  //     debugPrint('Error durante la inicialización de alarmas: $e');
  //   }
  // }

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
