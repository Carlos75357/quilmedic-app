import 'dart:ui';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/data/respository/alarm_repository.dart';
import 'package:quilmedic/domain/alarm.dart';

class AlarmUtils {
  static final ApiClient _apiClient = ApiClient();
  static final AlarmRepository alarmRepository = AlarmRepository(
    apiClient: _apiClient,
  );

  static final Map<int, List<Alarm>> _productAlarmCache = {};
  static final List<Alarm> _generalAlarmCache = [];

  Future<List<Alarm>> getGeneralExpirationDateAlarms() async {
    final response = await alarmRepository.getGeneralAlarms();
    if (response.success) {
      return (response.data as List<Alarm>)
          .where((alarm) => alarm.type!.toLowerCase() == 'date')
          .toList();
    }
    return [];
  }

  Future<List<Alarm>> getGeneralStockAlarms() async {
    final response = await alarmRepository.getGeneralAlarms();
    if (response.success) {
      return (response.data as List<Alarm>)
          .where((alarm) => alarm.type!.toLowerCase() == 'stock')
          .toList();
    }
    return [];
  }

  Future<List<Alarm>> getGeneralAlarms() async {
    final stockResponse = await getGeneralStockAlarms();
    final dateResponse = await getGeneralExpirationDateAlarms();
    return [...stockResponse, ...dateResponse];
  }

  Future<List<Alarm>> getExpirationDateAlarmByProduct(String productId) async {
    final response = await alarmRepository.getAlarmByProductId(productId);
    if (response.success && (response.data as List).isNotEmpty) {
      final alarm = (response.data as List<dynamic>)[0] as Alarm;
      if (alarm.type!.toLowerCase() == 'date') {
        return [alarm];
      }
    }
    return [];
  }

  Future<Alarm> getStockAlarmByProduct(String productId) async {
    final response = await alarmRepository.getAlarmByProductId(productId);
    if (response.success && (response.data as List).isNotEmpty) {
      final alarm = (response.data as List<dynamic>)[0] as Alarm;
      if (alarm.type!.toLowerCase() == 'stock') {
        return alarm;
      }
    }
    return Alarm();
  }

  Future<Color> setColorForStock(int stock, String? productId) async {
    Alarm alarm = await getStockAlarmByProduct(productId!);
    if (alarm.id != null) {
      final color = _parseColor(alarm.color!);
      if (color != null) {
        return color.withValues(alpha: 0.3);
      }
    }

    List<Alarm> alarmasLocal = await getGeneralStockAlarms();

    for (var alarma in alarmasLocal) {
      if (alarma.type!.toLowerCase() == 'stock') {
        if (_evaluateStockAlarm(alarma, stock)) {
          final color = _parseColor(alarma.color!);
          if (color != null) {
            return color.withValues(alpha: 0.3);
          }
        }
      }
    }


    throw Exception('No se encontraron alarmas de stock para el producto');
  }

  Future<Color> setColorExpirationDate(DateTime expiryDate, String? productId) async {
    List<Alarm> alarmaP = [];
    if (productId != null) {
      alarmaP = await getExpirationDateAlarmByProduct(productId);
    }

    if (alarmaP.isNotEmpty) {
      final color = _parseColor(alarmaP[0].color!);
      if (color != null) {
        return color.withValues(alpha: 0.3);
      }
    }

    List<Alarm> alarmasLocal = await ProductoLocalStorage.obtenerAlarmas();

    for (var alarma in alarmasLocal) {
      if (alarma.type!.toLowerCase() == 'date') {
        if (_evaluateExpiryAlarm(
          alarma,
          expiryDate.difference(DateTime.now()).inDays,
        )) {
          final color = _parseColor(alarma.color!);
          if (color != null) {
            return color.withValues(alpha: 0.3);
          }
        }
      }
    }
    throw Exception('No se encontraron alarmas de caducidad para el producto');
  }

  static bool _evaluateExpiryAlarm(Alarm alarm, int days) {
    final condition = alarm.condition;
    final RegExp regExp = RegExp(r'(\D*)(\d+)');
    final Match? match = regExp.firstMatch(condition!);

    if (match == null) return false;

    final operator = match.group(1)?.trim() ?? '';
    final value = int.parse(match.group(2)!);

    switch (operator) {
      case '<':
        return days < value;
      case '<=':
        return days <= value;
      case '>':
        return days > value;
      case '>=':
        return days >= value;
      case '=':
        return days == value;
      default:
        return false;
    }
  }

  static bool _evaluateStockAlarm(Alarm alarm, int stock) {
    final condition = alarm.condition;
    final RegExp regExp = RegExp(r'(\D*)(\d+)');
    final Match? match = regExp.firstMatch(condition!);

    if (match == null) return false;

    final operator = match.group(1)?.trim() ?? '';
    final value = int.parse(match.group(2)!);

    switch (operator) {
      case '<':
        return stock < value;
      case '<=':
        return stock <= value;
      case '>':
        return stock > value;
      case '>=':
        return stock >= value;
      case '=':
        return stock == value;
      default:
        return false;
    }
  }

  static Color? _parseColor(String color) {
    return Color.fromARGB(
      int.parse(color.split(',')[0]),
      int.parse(color.split(',')[1]),
      int.parse(color.split(',')[2]),
      int.parse(color.split(',')[3]),
    ).withValues(alpha: 0.3);
  }

  static void clearCache() {
    _productAlarmCache.clear();
    _generalAlarmCache.clear();
  }
}
