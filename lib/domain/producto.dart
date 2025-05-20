/// Clase que representa un producto médico en el sistema.
/// Contiene toda la información relevante de un producto como su identificador,
/// código, descripción, lote, ubicación, número de serie, fecha de caducidad y stock.
class Producto {
  /// Identificador único del producto (ID del modelo de producto)
  int id;
  /// Código del producto
  String productcode;
  /// Descripción o nombre del producto
  String? description;
  /// Número de lote del producto
  int numerolote;
  /// Identificador de la ubicación donde se encuentra el producto
  int locationid;
  /// Número de serie único del producto
  String serialnumber;
  /// Fecha de caducidad del producto
  DateTime expirationdate;
  /// Cantidad disponible del producto
  int stock;
  /// Stock mínimo esperado para este producto (opcional)
  int? minStock;

  /// Constructor de la clase Producto
  /// @param [id] Identificador único del producto
  /// @param [productcode] Código del producto
  /// @param [description] Descripción o nombre del producto
  /// @param [numerolote] Número de lote
  /// @param [locationid] ID de la ubicación donde se encuentra
  /// @param [serialnumber] Número de serie único
  /// @param [expirationdate] Fecha de caducidad
  /// @param [stock] Cantidad disponible
  /// @param [minStock] Stock mínimo esperado (opcional)
  Producto(
    this.id,
    this.productcode,
    this.description,
    this.numerolote,
    this.locationid,
    this.serialnumber,
    this.expirationdate,
    this.stock, {
    this.minStock,
  });

  /// Convierte la instancia actual a un mapa para almacenamiento local
  /// @return [Map] Mapa con los datos del producto
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productcode': productcode,
      'description': description,
      'numerolote': numerolote,
      'locationid': locationid,
      'serialnumber': serialnumber,
      'expirationdate': expirationdate,
      'stock': stock,
      'minStock': minStock,
    };
  }

  /// Constructor factory para crear una instancia de Producto desde un mapa
  /// almacenado localmente
  /// @param [map] Mapa con los datos del producto
  /// @return Nueva instancia de [Producto]
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      map['id'] ?? 0,
      map['productcode'] ?? 0,
      map['description'],
      map['numerolote'] ?? 0,
      map['locationid'] ?? 0,
      map['serialnumber'] ?? 0,
      DateTime.parse(map['expirationdate']),
      map['stock'] ?? 1,
      minStock: map['minStock'],
    );
  }

  /// Constructor factory para crear una instancia de Producto desde un mapa JSON
  /// proveniente de la API, con manejo de errores
  /// @param [map] Mapa con los datos en formato JSON de la API
  /// @return Nueva instancia de [Producto]
  factory Producto.fromApiMap(Map<String, dynamic> map) {
    try {
      return Producto(
        map['product_model_id'] ?? 0,
        map['product_code'] ?? '0',
        map['description'],
        map['numerolote'] ?? 0,
        map['location_id'] ?? 0,
        map['serial_number'] ?? '',
        map['expiration_date'] != null
            ? DateTime.parse(map['expiration_date'])
            : DateTime.now(),
        int.tryParse(map['stock']?.toString() ?? '0') ?? 0,
        minStock: int.tryParse(map['min_stock']?.toString() ?? ''),
      );
    } catch (e) {
      return Producto(
        0,
        '0',
        'Error al procesar producto',
        0,
        0,
        '',
        DateTime.now(),
        0,
      );
    }
  }
}
