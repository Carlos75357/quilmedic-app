import 'dart:convert';
import 'package:quilmedic/domain/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class ProductoLocalStorage {
  static const String _productosEscaneadosKey = 'productos_escaneados';
  static const String _productosPendientesKey = 'productos_pendientes';
  static const String _hospitalPendienteKey = 'hospital_pendiente';
  static const String _productosCompletos =  'productos_completos';
  static const String _alarmasKey = 'alarmas';
  
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
  
  static Future<bool> limpiarProductosEscaneados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_productosEscaneadosKey);
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> guardarProductosPendientes(List<ProductoEscaneado> productos, int hospitalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<Map<String, dynamic>> productosMap = 
          productos.map((p) => p.toMap()).toList();
      
      final String jsonString = jsonEncode(productosMap);
      
      await prefs.setInt(_hospitalPendienteKey, hospitalId);
      
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
  
  static Future<bool> limpiarProductosPendientes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hospitalPendienteKey);
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
  
  static Future<bool> eliminarProductoPendiente(String serie) async {
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
      
      productos.removeWhere((p) => p.serie == serie);
      
      if (productos.isEmpty) {
        return await limpiarProductosPendientes();
      }
      
      final int? hospitalId = await obtenerHospitalPendiente();
      if (hospitalId == null) {
        return false;
      }
      
      return await guardarProductosPendientes(productos, hospitalId);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> guardarProductosCompletos(List<ProductoEscaneado> productos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<Map<String, dynamic>> productosMap = 
          productos.map((p) => p.toMap()).toList();
      
      final String jsonString = jsonEncode(productosMap);
      
      return await prefs.setString(_productosCompletos, jsonString);
    } catch (e) {
      return false;
    }
  }

  static Future<List<ProductoEscaneado>> obtenerProductosCompletos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_productosCompletos);
      
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

  static Future<bool> limpiarProductosCompletos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_productosCompletos);
    } catch (e) {
      return false;
    }
  }

  static Future<Producto?> obtenerProductoPorSerie(String serie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_productosCompletos);
      
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      
      final List<dynamic> decodedList = jsonDecode(jsonString);
      final productos = decodedList.map((item) => Producto.fromMap(item as Map<String, dynamic>)).toList();
      
      for (var producto in productos) {
        if (producto.serie == serie) {
          return producto;
        }
      }
      
      return null;
    } catch (e) {
      return null;
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
