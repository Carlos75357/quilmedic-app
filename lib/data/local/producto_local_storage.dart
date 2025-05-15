import 'dart:convert';
import 'package:quilmedic/domain/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

/// Clase que gestiona el almacenamiento local de productos escaneados, productos pendientes
/// y alarmas utilizando SharedPreferences.
/// Proporciona métodos para guardar, obtener, agregar y eliminar información
/// relacionada con productos y alarmas en el almacenamiento local del dispositivo.
class ProductoLocalStorage {
  /// Clave para almacenar la lista de IDs de productos escaneados
  static const String _productosEscaneadosKey = 'productos_escaneados';
  /// Clave para almacenar la lista de productos pendientes de sincronización
  static const String _productosPendientesKey = 'productos_pendientes';
  /// Clave para almacenar el ID del hospital pendiente
  static const String _hospitalPendienteKey = 'hospital_pendiente';
  /// Clave para almacenar el ID de la ubicación pendiente
  static const String _locationPendienteKey = 'location_pendiente';
  /// Clave para almacenar las alarmas generales
  static const String _alarmasKey = 'alarmas';
  /// Clave para almacenar las alarmas específicas por producto
  static const String _alarmasKeyEspecificas = 'alarmas_especificas';
  
  /// Guarda la lista de IDs de productos escaneados en el almacenamiento local
  /// @param productosIds Lista de IDs de productos a guardar
  /// @return true si la operación fue exitosa, false en caso contrario
  static Future<bool> guardarProductosEscaneados(List<String> productosIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(productosIds);
      return await prefs.setString(_productosEscaneadosKey, jsonString);
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene la lista de IDs de productos escaneados del almacenamiento local
  /// @return Lista de IDs de productos escaneados, o lista vacía si no hay datos o ocurre un error
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
  
  /// Agrega un ID de producto a la lista de productos escaneados si no existe ya
  /// @param productoId ID del producto a agregar
  /// @return true si la operación fue exitosa, false en caso contrario
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
  
  /// Elimina un ID de producto de la lista de productos escaneados
  /// @param productoId ID del producto a eliminar
  /// @return true si la operación fue exitosa, false en caso contrario
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
  
  /// Guarda una lista de productos pendientes de sincronización junto con el hospital y ubicación
  /// @param productos Lista de productos escaneados pendientes
  /// @param hospitalId ID del hospital donde se escanearon los productos
  /// @param locationId ID opcional de la ubicación específica dentro del hospital
  /// @return true si la operación fue exitosa, false en caso contrario
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
  
  /// Obtiene la lista de productos pendientes de sincronización
  /// @return Lista de productos pendientes, o lista vacía si no hay datos o ocurre un error
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
  
  /// Obtiene el ID del hospital asociado a los productos pendientes
  /// @return ID del hospital o null si no existe o ocurre un error
  static Future<int?> obtenerHospitalPendiente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_hospitalPendienteKey);
    } catch (e) {
      return null;
    }
  }
  
  /// Obtiene el ID de la ubicación asociada a los productos pendientes
  /// @return ID de la ubicación o null si no existe o ocurre un error
  static Future<int?> obtenerLocationPendiente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_locationPendienteKey);
    } catch (e) {
      return null;
    }
  }
  
  /// Elimina todos los datos relacionados con productos pendientes (productos, hospital y ubicación)
  /// @return true si la operación fue exitosa, false en caso contrario
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
  
  /// Verifica si hay productos pendientes de sincronización
  /// @return true si existen productos pendientes, false en caso contrario
  static Future<bool> hayProductosPendientes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_productosPendientesKey);
    return jsonString != null && jsonString.isNotEmpty;
  }
  
  /// Elimina un producto específico de la lista de productos pendientes por su número de serie
  /// Si la lista queda vacía, limpia todos los datos de productos pendientes
  /// @param serialnumber Número de serie del producto a eliminar
  /// @return true si la operación fue exitosa, false en caso contrario
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

  /// Agrega una alarma a la lista de alarmas generales
  /// Si no existen alarmas previas, crea una nueva lista
  /// @param alarm Alarma a agregar
  /// @return true si la operación fue exitosa, false en caso contrario
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

  /// Reemplaza todas las alarmas generales con una nueva lista
  /// @param alarms Lista de alarmas a guardar
  /// @return true si la operación fue exitosa, false en caso contrario
  static Future<bool> agregarAlarmas(List<Alarm> alarms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_alarmasKey, jsonEncode(alarms.map((a) => a.toMap()).toList()));
    } catch (e) {
      return false;
    }
  }

  /// Reemplaza todas las alarmas específicas por producto con una nueva lista
  /// @param alarms Lista de alarmas específicas a guardar
  /// @return true si la operación fue exitosa, false en caso contrario
  static Future<bool> agregarAlarmasEspecificas(List<Alarm> alarms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_alarmasKeyEspecificas, jsonEncode(alarms.map((a) => a.toMap()).toList()));
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la lista de alarmas específicas por producto
  /// @return Lista de alarmas específicas, o lista vacía si no hay datos o ocurre un error
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

  /// Obtiene la lista de alarmas generales
  /// @return Lista de alarmas generales, o lista vacía si no hay datos o ocurre un error
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
