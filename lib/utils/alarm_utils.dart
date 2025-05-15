import 'dart:core';

import 'package:flutter/material.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/data/respository/alarm_repository.dart';
import 'package:quilmedic/domain/alarm.dart';
import 'package:quilmedic/domain/alarm_info.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmUtils {
  static final ApiClient _apiClient = ApiClient();
  static final AlarmRepository alarmRepository = AlarmRepository(
    apiClient: _apiClient,
  );

  static final Map<int, List<Alarm>> _productAlarmCache = {};
  static final List<Alarm> _generalAlarmCache = [];
  static final Map<int, AlarmInfo> _stockColorCache = {};
  static final Map<int, AlarmInfo> _expiryColorCache = {};

  static const String _lastUpdateKey = 'last_alarm_update';
  static const int _cacheExpirationHours = 24;

  Future<void> initGeneralAlarms() async {
    try {
      if (_generalAlarmCache.isEmpty || await _shouldRefreshCache()) {
        try {
          final stockResponse = await getGeneralStockAlarms();
          final dateResponse = await getGeneralExpirationDateAlarms();

          _generalAlarmCache.clear();
          _generalAlarmCache.addAll([...stockResponse, ...dateResponse]);

          await ProductoLocalStorage.agregarAlarmas(_generalAlarmCache);
          await _updateLastRefreshTime();
        } catch (e) {
          await loadAlarmsFromCache();
        }
      }
    } catch (e) {
      await loadAlarmsFromCache();
    }
  }

  Future<bool> _shouldRefreshCache() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);

    if (lastUpdate == null) {
      return true;
    }

    final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    final now = DateTime.now();
    final difference = now.difference(lastUpdateTime).inHours;

    return difference >= _cacheExpirationHours;
  }

  Future<void> _updateLastRefreshTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> loadAlarmsFromCache() async {
    try {
      if (_generalAlarmCache.isEmpty) {
        final alarms = await ProductoLocalStorage.obtenerAlarmas();
        if (alarms.isNotEmpty) {
          _generalAlarmCache.clear();
          _generalAlarmCache.addAll(alarms);
        }
      }
    } catch (e) {
      _generalAlarmCache.clear();
    }
  }

  Future<List<Alarm>> getGeneralExpirationDateAlarms() async {
    try {
      final response = await alarmRepository.getGeneralAlarms();
      if (response.success) {
        return (response.data as List<Alarm>)
            .where((alarm) => alarm.type!.toLowerCase() == 'date')
            .toList();
      }
    } catch (e) {
      _generalAlarmCache.clear();
    }
    return [];
  }

  Future<List<Alarm>> getGeneralStockAlarms() async {
    try {
      final response = await alarmRepository.getGeneralAlarms();
      if (response.success) {
        return (response.data as List<Alarm>)
            .where((alarm) => alarm.type!.toLowerCase() == 'stock')
            .toList();
      }
    } catch (e) {
      _generalAlarmCache.clear();
    }
    return [];
  }

  Future<List<Alarm>> getGeneralAlarms() async {
    if (_generalAlarmCache.isNotEmpty) {
      return List.from(_generalAlarmCache);
    }

    await loadAlarmsFromCache();
    if (_generalAlarmCache.isNotEmpty) {
      return List.from(_generalAlarmCache);
    }

    final stockResponse = await getGeneralStockAlarms();
    final dateResponse = await getGeneralExpirationDateAlarms();
    final generalAlarms = [...stockResponse, ...dateResponse];

    if (generalAlarms.isNotEmpty) {
      await saveAlarmsToCache(generalAlarms);
    }

    return generalAlarms;
  }

  Future<void> saveAlarmsToCache(List<Alarm> alarms) async {
    try {
      if (alarms.isNotEmpty) {
        _generalAlarmCache.clear();
        _generalAlarmCache.addAll(alarms);

        await ProductoLocalStorage.agregarAlarmas(alarms);
      }
    } catch (e) {
      _generalAlarmCache.clear();
    }
  }

  bool hasSpecificAlarms(int? productId) {
    if (productId == null) return false;

    final hasAlarms = _stockColorCache.containsKey(productId);

    return hasAlarms;
  }

  Future<List<Alarm>> getSpecificAlarmsForProduct(int? productId) async {
    if (productId == null) return [];

    if (_productAlarmCache.containsKey(productId) &&
        _productAlarmCache[productId]!.isNotEmpty) {
      return _productAlarmCache[productId]!;
    }

    try {
      final specificAlarms =
          await ProductoLocalStorage.obtenerAlarmasEspecificas();
      final productSpecificAlarms =
          specificAlarms
              .where((alarm) => alarm.productId == productId)
              .toList();

      if (productSpecificAlarms.isNotEmpty) {
        _productAlarmCache[productId] = productSpecificAlarms;

        return productSpecificAlarms;
      }
    } catch (e) {
      _productAlarmCache[productId] = [];
    }

    return [];
  }

  Future<void> loadAlarmsForProducts(List<Producto> productos) async {
    Map<int, AlarmInfo> stockColorsMap = {};
    Map<int, AlarmInfo> expiryColorsMap = {};

    await loadAlarmsFromCache();

    List<int> productIds = productos.map((p) => p.id).toList();

    if (productIds.isEmpty) {
      return;
    }

    try {
      final response = await alarmRepository.getAlarmsByProducts(productIds);
      if (response.success && response.data is List<Alarm>) {
        List<Alarm> alarms = response.data;

        await ProductoLocalStorage.agregarAlarmasEspecificas(alarms);

        for (var alarm in alarms) {
          if (alarm.productId != null) {
            final color = _parseColor(alarm.color);
            if (color != null) {
              if (alarm.type?.toLowerCase() == 'stock') {
                stockColorsMap[alarm.productId!] = AlarmInfo(
                  productId: alarm.productId!,
                  condition: alarm.condition!,
                  locationId: alarm.locationId,
                );
              } else if (alarm.type?.toLowerCase() == 'date') {
                expiryColorsMap[alarm.productId!] = AlarmInfo(
                  productId: alarm.productId!,
                  condition: alarm.condition!,
                  color: color,
                );
              }
            }
          }
        }
      }
    } catch (e) {
      _stockColorCache.clear();
      _expiryColorCache.clear();
    }

    _stockColorCache.addAll(stockColorsMap);
    _expiryColorCache.addAll(expiryColorsMap);
  }

  Color getColorForStockFromCache(int stock, int? productId, int locationId) {
    if (productId != null) {
      if (_stockColorCache.containsKey(productId) &&
          _stockColorCache[productId]!.locationId == locationId) {
        if (_evaluateAlarm(_stockColorCache[productId]!.condition!, stock)) {
          return Color.fromARGB(255, 233, 236, 11).withValues(alpha: 0.3);
        }
        return const Color.fromARGB(255, 37, 238, 44).withValues(alpha: 0.3);
      }
      return const Color.fromARGB(255, 82, 83, 82).withValues(alpha: 0.3);
    }
    return Colors.green.withValues(alpha: 0.3);
  }

  Color getColorForExpiryFromCache(int? productId, [DateTime? expiryDate]) {
    if (productId != null && _expiryColorCache.containsKey(productId)) {
      if (_evaluateAlarm(
        _expiryColorCache[productId]!.condition!,
        expiryDate!.difference(DateTime.now()).inDays,
      )) {
        return _expiryColorCache[productId]!.color!;
      }
    }
    for (var alarm in _generalAlarmCache) {
      if (alarm.type?.toLowerCase() == 'date') {
        if (_evaluateAlarm(
          alarm.condition!,
          expiryDate!.difference(DateTime.now()).inDays,
        )) {
          return _parseColor(alarm.color) ??
              Colors.green.withValues(alpha: 0.3);
        }
      }
    }
    return Colors.green.withValues(alpha: 0.3);
  }

  static bool _evaluateAlarm(String condition, int days) {
    final value = _getValue(condition);

    switch (_getOperator(condition)) {
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

  static int _getValue(String condition) {
    final RegExp regExp = RegExp(r'(\D*)(\d+)');
    final Match? match = regExp.firstMatch(condition);

    if (match == null) return 0;

    final value = int.parse(match.group(2)!);

    return value;
  }

  static String _getOperator(String? condition) {
    final RegExp regExp = RegExp(r'(\D*)(\d+)');
    final Match? match = regExp.firstMatch(condition!);

    if (match == null) return '';

    final operator = match.group(1)?.trim() ?? '';

    return operator;
  }

  static Color? _parseColor(String? color) {
    if (color == null) {
      return const Color.fromARGB(255, 189, 47, 214).withValues(alpha: 0.3);
    }

    try {
      return Color.fromARGB(
        int.parse(color.split(',')[0]),
        int.parse(color.split(',')[1]),
        int.parse(color.split(',')[2]),
        int.parse(color.split(',')[3]),
      ).withValues(alpha: 0.3);
    } catch (e) {
      return const Color.fromARGB(255, 189, 47, 214).withValues(alpha: 0.3);
    }
  }

  static void clearCache() {
    _productAlarmCache.clear();
    _generalAlarmCache.clear();
    _stockColorCache.clear();
    _expiryColorCache.clear();
  }

  Future<void> forceRefresh() async {
    try {
      await initGeneralAlarms();
      await _updateLastRefreshTime();
    } catch (e) {
      await loadAlarmsFromCache();
    }
  }
}
