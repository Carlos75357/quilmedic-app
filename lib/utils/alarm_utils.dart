import 'dart:core';

import 'package:flutter/material.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/data/respository/alarm_repository.dart';
import 'package:quilmedic/domain/alarm.dart';
import 'package:quilmedic/domain/producto.dart';

class AlarmUtils {
  static final ApiClient _apiClient = ApiClient();
  static final AlarmRepository alarmRepository = AlarmRepository(
    apiClient: _apiClient,
  );

  static final Map<String, List<Alarm>> _productAlarmCache = {};
  static final List<Alarm> _generalAlarmCache = [];
  static final Map<String, Color> _stockColorCache = {};
  static final Map<String, Color> _expiryColorCache = {};

  Future<void> initGeneralAlarms() async {
    if (_generalAlarmCache.isEmpty) {
      final stockResponse = await getGeneralStockAlarms();
      final dateResponse = await getGeneralExpirationDateAlarms();
      
      _generalAlarmCache.clear();
      _generalAlarmCache.addAll([...stockResponse, ...dateResponse]);
      
      await ProductoLocalStorage.agregarAlarmas(_generalAlarmCache);
    }
  }

  Future<void> loadAlarmsFromCache() async {
    if (_generalAlarmCache.isEmpty) {
      final alarms = await ProductoLocalStorage.obtenerAlarmas();
      if (alarms.isNotEmpty) {
        _generalAlarmCache.clear();
        _generalAlarmCache.addAll(alarms);
      } else {
        await initGeneralAlarms();
      }
    }
  }

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

  Future<Map<String, Color>> loadStockColorsForProducts(
    List<Producto> productos,
  ) async {
    Map<String, Color> colorsMap = {};

    await loadAlarmsFromCache();

    List<String> productIds = productos.map((p) => p.productcode.toString()).toList();

    try {
      final response = await alarmRepository.getAlarmsByProducts(
        productIds,
      );
      if (response.success && response.data is List<Alarm>) {
        List<Alarm> alarms = response.data;

        await ProductoLocalStorage.agregarAlarmasEspecificas(alarms);

        for (var alarm in alarms) {
          if (alarm.type?.toLowerCase() == 'stock' &&
              alarm.productId != null &&
              alarm.color != null) {
            final color = _parseColor(alarm.color!);
            if (color != null) {
              colorsMap[alarm.productId!.toString()] = color;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error al cargar alarmas específicas: $e');

    }

    for (var producto in productos) {
      final productId = producto.productcode.toString();
      if (!colorsMap.containsKey(productId)) {
        final stockAlarms = _generalAlarmCache
            .where((a) => a.type?.toLowerCase() == 'stock')
            .toList();
            
        for (var alarm in stockAlarms) {
          if (_evaluateStockAlarm(alarm, producto.stock)) {
            final color = _parseColor(alarm.color!);
            if (color != null) {
              colorsMap[productId] = color;
              break;
            }
          }
        }
      }
    }

    _stockColorCache.addAll(colorsMap);

    return colorsMap;
  }
  
  Future<Map<String, Color>> loadExpiryColorsForProducts(
    List<Producto> productos,
  ) async {
    Map<String, Color> colorsMap = {};

    await loadAlarmsFromCache();

    List<String> serialnumbersList = productos.map((p) => p.serialnumber).toList();

    try {
      final response = await alarmRepository.getAlarmsByProducts(serialnumbersList);
      if (response.success && response.data is List<Alarm>) {
        List<Alarm> alarms = response.data;

        await ProductoLocalStorage.agregarAlarmasEspecificas(alarms);

        for (var alarm in alarms) {
          if (alarm.type?.toLowerCase() == 'date' &&
              alarm.productId != null &&
              alarm.color != null) {
            final color = _parseColor(alarm.color!);
            if (color != null) {
              colorsMap[alarm.productId!.toString()] = color;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error al cargar alarmas específicas: $e');
    }

    for (var producto in productos) {
      if (!colorsMap.containsKey(producto.serialnumber)) {
        final days = producto.expirationdate.difference(DateTime.now()).inDays;
        
        final dateAlarms = _generalAlarmCache
            .where((a) => a.type?.toLowerCase() == 'date')
            .toList();
            
        for (var alarm in dateAlarms) {
          if (_evaluateExpiryAlarm(alarm, days)) {
            final color = _parseColor(alarm.color!);
            if (color != null) {
              colorsMap[producto.serialnumber] = color;
              break;
            }
          }
        }
      }
    }

    _expiryColorCache.addAll(colorsMap);

    return colorsMap;
  }

  Color getColorForStockFromCache(int stock, String? productId) {
    if (productId != null && _stockColorCache.containsKey(productId)) {
      return _stockColorCache[productId]!;
    }
    
    final stockAlarms = _generalAlarmCache
        .where((a) => a.type?.toLowerCase() == 'stock')
        .toList();
        
    for (var alarm in stockAlarms) {
      if (_evaluateStockAlarm(alarm, stock)) {
        final color = _parseColor(alarm.color!);
        if (color != null) {
          return color;
        }
      }
    }
    
    return Colors.grey.withValues(alpha: 0.3);
  }

  Color getColorForExpiryFromCache(String? productId, [DateTime? expiryDate]) {
    if (productId != null && _expiryColorCache.containsKey(productId)) {
      return _expiryColorCache[productId]!;
    }
    
    if (expiryDate != null) {
      final days = expiryDate.difference(DateTime.now()).inDays;
      
      final dateAlarms = _generalAlarmCache
          .where((a) => a.type?.toLowerCase() == 'date')
          .toList();
          
      for (var alarm in dateAlarms) {
        if (_evaluateExpiryAlarm(alarm, days)) {
          final color = _parseColor(alarm.color!);
          if (color != null) {
            return color;
          }
        }
      }
    }
    
    return Colors.grey.withValues(alpha: 0.3);
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
    try {
      return Color.fromARGB(
        int.parse(color.split(',')[0]),
        int.parse(color.split(',')[1]),
        int.parse(color.split(',')[2]),
        int.parse(color.split(',')[3]),
      ).withValues(alpha: 0.3);
    } catch (e) {
      return null;
    }
  }

  static void clearCache() {
    _productAlarmCache.clear();
    _generalAlarmCache.clear();
    _stockColorCache.clear();
    _expiryColorCache.clear();
  }
}
