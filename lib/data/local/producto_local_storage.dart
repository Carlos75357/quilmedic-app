import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class ProductoLocalStorage {
  static const String _productosEscaneadosKey = 'productos_escaneados';
  static const String _productosPendientesKey = 'productos_pendientes';
  static const String _hospitalPendienteKey = 'hospital_pendiente';
  
  static Future<bool> guardarProductosEscaneados(List<int> productosIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(productosIds);
      return await prefs.setString(_productosEscaneadosKey, jsonString);
    } catch (e) {
      return false;
    }
  }
  
  static Future<List<int>> obtenerProductosEscaneados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_productosEscaneadosKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map<int>((item) => item as int).toList();
    } catch (e) {
      return [];
    }
  }
  
  static Future<bool> agregarProductoEscaneado(int productoId) async {
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
  
  static Future<bool> eliminarProductoEscaneado(int productoId) async {
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
    final String? productosJson = prefs.getString('productos_pendientes');
    
    if (productosJson == null || productosJson.isEmpty) {
      return false;
    }
    
    try {
      final List<dynamic> decodedData = jsonDecode(productosJson);
      return decodedData.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
