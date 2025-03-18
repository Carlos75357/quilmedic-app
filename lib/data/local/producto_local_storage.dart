import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductoLocalStorage {
  static const String _productosEscaneadosKey = 'productos_escaneados';
  
  static Future<bool> guardarProductosEscaneados(List<int> productosIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(productosIds);
      return await prefs.setString(_productosEscaneadosKey, jsonString);
    } catch (e) {
      return false;
    }
  }
  
  static Future<List<int>> obtenerProductosEscaneados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_productosEscaneadosKey);
      
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
}
