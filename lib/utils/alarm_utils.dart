import 'dart:core';

import 'package:flutter/material.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/data/respository/alarm_repository.dart';
import 'package:quilmedic/domain/alarm.dart';
import 'package:quilmedic/domain/alarm_info.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utilidad para gestionar las alarmas de productos
/// Proporciona métodos para obtener, evaluar y almacenar en caché las alarmas
/// relacionadas con fechas de caducidad y niveles de stock
class AlarmUtils {
  /// Cliente API para realizar peticiones al servidor
  static final ApiClient _apiClient = ApiClient();
  /// Repositorio para gestionar operaciones con alarmas
  static final AlarmRepository alarmRepository = AlarmRepository(
    apiClient: _apiClient,
  );

  /// Caché de alarmas específicas por producto
  static final Map<int, List<Alarm>> _productAlarmCache = {};
  /// Caché de alarmas generales
  static final List<Alarm> _generalAlarmCache = [];
  /// Caché de información de colores para alarmas de stock
  static final Map<int, AlarmInfo> _stockColorCache = {};
  /// Caché de información de colores para alarmas de caducidad
  static final Map<int, AlarmInfo> _expiryColorCache = {};

  /// Clave para almacenar la última actualización de alarmas en SharedPreferences
  static const String _lastUpdateKey = 'last_alarm_update';
  /// Tiempo de expiración de la caché en horas
  static const int _cacheExpirationHours = 24;

  /// Inicializa las alarmas generales
  /// Intenta cargar las alarmas desde el servidor y las guarda en caché
  /// Si falla, carga las alarmas desde la caché local
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

  /// Determina si la caché de alarmas debe actualizarse
  /// @return true si la caché ha expirado o no existe, false en caso contrario
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

  /// Actualiza el tiempo de la última actualización de la caché
  /// Guarda la marca de tiempo actual en SharedPreferences
  Future<void> _updateLastRefreshTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Carga las alarmas generales desde la caché local
  /// Se utiliza cuando no se pueden obtener las alarmas del servidor
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

  /// Obtiene las alarmas generales relacionadas con fechas de caducidad
  /// @return Lista de alarmas de tipo 'date'
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

  /// Obtiene las alarmas generales relacionadas con niveles de stock
  /// @return Lista de alarmas de tipo 'stock'
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

  /// Obtiene todas las alarmas generales (caducidad y stock)
  /// Primero intenta usar la caché, luego la caché local, y finalmente el servidor
  /// @return Lista combinada de todas las alarmas generales
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

  /// Guarda las alarmas en la caché y actualiza el tiempo de actualización
  /// @param alarms Lista de alarmas a guardar en caché
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

  /// Verifica si un producto tiene alarmas específicas
  /// @param productId ID del producto a verificar
  /// @return true si el producto tiene alarmas específicas, false en caso contrario
  bool hasSpecificAlarms(int? productId) {
    if (productId == null) return false;

    final hasAlarms = _stockColorCache.containsKey(productId);

    return hasAlarms;
  }

  /// Obtiene las alarmas específicas para un producto
  /// @param productId ID del producto
  /// @return Lista de alarmas específicas para el producto
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

  /// Carga las alarmas para una lista de productos
  /// Actualiza las cachés de colores para stock y caducidad
  /// @param productos Lista de productos para los que cargar alarmas
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

  /// Obtiene el color para el nivel de stock de un producto
  /// Primero busca alarmas específicas, luego usa el valor por defecto
  /// @param stock Nivel de stock actual
  /// @param productId ID del producto
  /// @param locationId ID de la ubicación
  /// @return Color correspondiente al nivel de stock
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

  /// Obtiene el color para la fecha de caducidad de un producto
  /// Primero busca alarmas específicas, luego usa las alarmas generales
  /// @param productId ID del producto
  /// @param expiryDate Fecha de caducidad
  /// @return Color correspondiente a la fecha de caducidad
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

  /// Evalúa una condición de alarma contra un valor
  /// @param condition Condición en formato operador+valor (ej: '<30', '>=10')
  /// @param days Valor a comparar (días o cantidad)
  /// @return true si la condición se cumple, false en caso contrario
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

  /// Extrae el valor numérico de una condición
  /// @param condition Condición en formato operador+valor (ej: '<30', '>=10')
  /// @return Valor numérico extraído de la condición
  static int _getValue(String condition) {
    final RegExp regExp = RegExp(r'(\D*)(\d+)');
    final Match? match = regExp.firstMatch(condition);

    if (match == null) return 0;

    final value = int.parse(match.group(2)!);

    return value;
  }

  /// Extrae el operador de una condición
  /// @param condition Condición en formato operador+valor (ej: '<30', '>=10')
  /// @return Operador extraído de la condición (<, <=, >, >=, =)
  static String _getOperator(String? condition) {
    final RegExp regExp = RegExp(r'(\D*)(\d+)');
    final Match? match = regExp.firstMatch(condition!);

    if (match == null) return '';

    final operator = match.group(1)?.trim() ?? '';

    return operator;
  }

  /// Convierte una cadena de color en un objeto Color
  /// @param color Cadena con formato 'alpha,red,green,blue'
  /// @return Objeto Color correspondiente o color morado por defecto
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

  /// Limpia todas las cachés de alarmas
  /// Útil cuando se quiere forzar una recarga desde el servidor
  static void clearCache() {
    _productAlarmCache.clear();
    _generalAlarmCache.clear();
    _stockColorCache.clear();
    _expiryColorCache.clear();
  }

  /// Fuerza una actualización de las alarmas desde el servidor
  /// Útil cuando se sabe que han cambiado las configuraciones de alarmas
  Future<void> forceRefresh() async {
    try {
      await initGeneralAlarms();
      await _updateLastRefreshTime();
    } catch (e) {
      await loadAlarmsFromCache();
    }
  }
}
