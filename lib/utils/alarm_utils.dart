import 'dart:ui';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  // Future<List<Alarm>> getAlarmasEspecificas() async {
  //   final response = await alarmRepository.getAlarmsByProducts();
  //   if (response.success) {
  //     return response.data as List<Alarm>;
  //   }
  //   return [];
  // }

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

  Future<Map<String, Color>> loadStockColorsForProducts(List<Producto> productos) async {
    Map<String, Color> colorsMap = {};
    
    List<String> seriesList = productos.map((p) => p.serie).toList();
    
    try {
      final response = await alarmRepository.getAlarmsByProducts(seriesList);
      if (response.success && response.data is List<Alarm>) {
        List<Alarm> alarms = response.data;
        
        await ProductoLocalStorage.agregarAlarmasStock(alarms);
        
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
      print('Error al cargar alarmas específicas: $e');
    }
    
    List<Alarm> generalStockAlarms = await ProductoLocalStorage.obtenerAlarmas();
    if (generalStockAlarms.isEmpty) {
      generalStockAlarms = await getGeneralStockAlarms();
      await ProductoLocalStorage.agregarAlarmas(generalStockAlarms);
    }
    
    for (var producto in productos) {
      if (!colorsMap.containsKey(producto.serie)) {
        for (var alarm in generalStockAlarms) {
          if (alarm.type?.toLowerCase() == 'stock' && 
              _evaluateStockAlarm(alarm, producto.cantidad)) {
            final color = _parseColor(alarm.color!);
            if (color != null) {
              colorsMap[producto.serie] = color;
              break;
            }
          }
        }
      }
    }
    
    _stockColorCache.addAll(colorsMap);
    
    return colorsMap;
  }
  
  Future<Map<String, Color>> loadExpiryColorsForProducts(List<Producto> productos) async {
    Map<String, Color> colorsMap = {};
    
    List<String> seriesList = productos.map((p) => p.serie).toList();
    
    try {
      final response = await alarmRepository.getAlarmsByProducts(seriesList);
      if (response.success && response.data is List<Alarm>) {
        List<Alarm> alarms = response.data;
        
        await ProductoLocalStorage.agregarAlarmasStock(alarms);
        
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
      print('Error al cargar alarmas específicas: $e');
    }
    
    List<Alarm> generalExpiryAlarms = await ProductoLocalStorage.obtenerAlarmas();
    if (generalExpiryAlarms.isEmpty) {
      generalExpiryAlarms = await getGeneralExpirationDateAlarms();
      await ProductoLocalStorage.agregarAlarmas(generalExpiryAlarms);
    }
    
    for (var producto in productos) {
      if (!colorsMap.containsKey(producto.serie)) {
        final days = producto.fechacaducidad.difference(DateTime.now()).inDays;
        for (var alarm in generalExpiryAlarms) {
          if (alarm.type?.toLowerCase() == 'date' && 
              _evaluateExpiryAlarm(alarm, days)) {
            final color = _parseColor(alarm.color!);
            if (color != null) {
              colorsMap[producto.serie] = color;
              break;
            }
          }
        }
      }
    }
    
    _expiryColorCache.addAll(colorsMap);
    
    return colorsMap;
  }

  Future<Color> setColorForStock(int stock, String? productId) async {
    if (productId != null && _stockColorCache.containsKey(productId)) {
      return _stockColorCache[productId]!;
    }
    
    try {
      Alarm alarm = await getStockAlarmByProduct(productId ?? '');
      if (alarm.id != null) {
        final color = _parseColor(alarm.color!);
        if (color != null) {
          if (productId != null) {
            _stockColorCache[productId] = color;
          }
          return color;
        }
      }

      List<Alarm> alarmasLocal = await getGeneralStockAlarms();

      for (var alarma in alarmasLocal) {
        if (alarma.type!.toLowerCase() == 'stock') {
          if (_evaluateStockAlarm(alarma, stock)) {
            final color = _parseColor(alarma.color!);
            if (color != null) {
              if (productId != null) {
                _stockColorCache[productId] = color;
              }
              return color;
            }
          }
        }
      }
      
      // Si no se encontró ninguna alarma que coincida, devolver un color predeterminado
      return Colors.grey;
    } catch (e) {
      print('Error al obtener color para stock: $e');
      return Colors.grey;
    }
  }

  Color getColorForStockFromCache(int stock, String? productId) {
    if (productId != null && _stockColorCache.containsKey(productId)) {
      return _stockColorCache[productId]!;
    }
    return Colors.grey;
  }

  Color getColorForExpiryFromCache(String? productId) {
    if (productId != null && _expiryColorCache.containsKey(productId)) {
      return _expiryColorCache[productId]!;
    }
    return Colors.grey;
  }

  Future<Color> setColorExpirationDate(DateTime expiryDate, String? productId) async {
    // Verificar si ya tenemos el color en caché
    if (productId != null && _expiryColorCache.containsKey(productId)) {
      return _expiryColorCache[productId]!;
    }
    
    try {
      List<Alarm> alarms = await getExpirationDateAlarmByProduct(productId ?? '');
      if (alarms.isNotEmpty && alarms[0].id != null) {
        final color = _parseColor(alarms[0].color!);
        if (color != null) {
          if (productId != null) {
            _expiryColorCache[productId] = color;
          }
          return color;
        }
      }

      List<Alarm> alarmasLocal = await getGeneralExpirationDateAlarms();
      final days = expiryDate.difference(DateTime.now()).inDays;

      for (var alarma in alarmasLocal) {
        if (alarma.type!.toLowerCase() == 'date') {
          if (_evaluateExpiryAlarm(alarma, days)) {
            final color = _parseColor(alarma.color!);
            if (color != null) {
              if (productId != null) {
                _expiryColorCache[productId] = color;
              }
              return color;
            }
          }
        }
      }
      
      // Si no se encontró ninguna alarma que coincida, devolver un color predeterminado
      return Colors.grey;
    } catch (e) {
      print('Error al obtener color para fecha de caducidad: $e');
      return Colors.grey;
    }
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
      print('Error parsing color: $e');
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
