import 'dart:convert';
import 'package:quilmedic/domain/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class ProductoLocalStorage {
  static const String _productosEscaneadosKey = 'productos_escaneados';
  static const String _productosPendientesKey = 'productos_pendientes';
  static const String _hospitalPendienteKey = 'hospital_pendiente';
  static const String _locationPendienteKey = 'location_pendiente';
  static const String _alarmasKey = 'alarmas';
  static const String _alarmasKeyEspecificas = 'alarmas_especificas';
  
  static Future<bool> guardarProductosEscaneados(List<String> productosIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(productosIds);
      return await prefs.setString(_productosEscaneadosKey, jsonString);
    } catch (e) {
      return false;
    }
  }
  
  static Future<List<String>> obtenerProductosEscaneados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_productosEscaneadosKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map<String>((item) => item).toList();
    } catch (e) {
      return [];
    }
  }
  
  static Future<bool> agregarProductoEscaneado(String productoId) async {
    try {
      final productosIds = await obtenerProductosEscaneados();
      
      if (!productosIds.contains(productoId)) {
        productosIds.add(productoId);
        return await guardarProductosEscaneados(productosIds);
      }
      
      return true; 
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> eliminarProductoEscaneado(String productoId) async {
    try {
      final productosIds = await obtenerProductosEscaneados();
      
      if (productosIds.contains(productoId)) {
        productosIds.remove(productoId);
        return await guardarProductosEscaneados(productosIds);
      }
      
      return true; 
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> guardarProductosPendientes(List<ProductoEscaneado> productos, int hospitalId, int? locationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<Map<String, dynamic>> productosMap = 
          productos.map((p) => p.toMap()).toList();
      
      final String jsonString = jsonEncode(productosMap);
      
      await prefs.setInt(_hospitalPendienteKey, hospitalId);
      await prefs.setInt(_locationPendienteKey, locationId ?? 0);
      
      return await prefs.setString(_productosPendientesKey, jsonString);
    } catch (e) {
      return false;
    }
  }
  
  static Future<List<ProductoEscaneado>> obtenerProductosPendientes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_productosPendientesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList
          .map<ProductoEscaneado>((item) => ProductoEscaneado.fromMap(item))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  static Future<int?> obtenerHospitalPendiente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_hospitalPendienteKey);
    } catch (e) {
      return null;
    }
  }
  
  static Future<int?> obtenerLocationPendiente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_locationPendienteKey);
    } catch (e) {
      return null;
    }
  }
  
  static Future<bool> limpiarProductosPendientes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hospitalPendienteKey);
      await prefs.remove(_locationPendienteKey);
      return await prefs.remove(_productosPendientesKey);
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> hayProductosPendientes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_productosPendientesKey);
    return jsonString != null && jsonString.isNotEmpty;
  }
  
  static Future<bool> eliminarProductoPendiente(String serialnumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_productosPendientesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return true; 
      }
      
      final List<dynamic> decodedList = jsonDecode(jsonString);
      final List<ProductoEscaneado> productos = decodedList
          .map<ProductoEscaneado>((item) => ProductoEscaneado.fromMap(item))
          .toList();
      
      productos.removeWhere((p) => p.serialnumber == serialnumber);
      
      if (productos.isEmpty) {
        return await limpiarProductosPendientes();
      }
      
      final int? hospitalId = await obtenerHospitalPendiente();
      final int? locationId = await obtenerLocationPendiente();
      if (hospitalId == null || locationId == null) {
        return false;
      }
      
      return await guardarProductosPendientes(productos, hospitalId, locationId);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> agregarAlarma(Alarm alarm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_alarmasKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return await prefs.setString(_alarmasKey, jsonEncode([alarm.toMap()]));
      }
      
      final List<dynamic> decodedList = jsonDecode(jsonString);
      final List<Alarm> alarms = decodedList.map((item) => Alarm.fromMap(item)).toList();
      
      alarms.add(alarm);
      
      return await prefs.setString(_alarmasKey, jsonEncode(alarms.map((a) => a.toMap()).toList()));
    } catch (e) {
      return false;
    }
  }

  static Future<bool> agregarAlarmas(List<Alarm> alarms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_alarmasKey, jsonEncode(alarms.map((a) => a.toMap()).toList()));
    } catch (e) {
      return false;
    }
  }

  static Future<bool> agregarAlarmasEspecificas(List<Alarm> alarms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_alarmasKeyEspecificas, jsonEncode(alarms.map((a) => a.toMap()).toList()));
    } catch (e) {
      return false;
    }
  }

  static Future<List<Alarm>> obtenerAlarmasEspecificas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_alarmasKeyEspecificas);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((item) => Alarm.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Alarm>> obtenerAlarmas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_alarmasKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((item) => Alarm.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }
}
