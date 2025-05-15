/// Clase que representa un producto escaneado con el lector de códigos.
/// A diferencia de la clase Producto, esta solo contiene el número de serie
/// ya que es la única información obtenida durante el escaneo inicial.
class ProductoEscaneado {
  /// Número de serie único del producto escaneado
  final String serialnumber;

  /// Constructor de la clase ProductoEscaneado
  /// @param serialnumber Número de serie del producto escaneado
  ProductoEscaneado(this.serialnumber);

  /// Convierte la instancia actual a un mapa para almacenamiento local
  /// @return Mapa con el número de serie del producto
  Map<String, dynamic> toMap() {
    return {
      'serialnumber': serialnumber,
    };
  }

  /// Constructor factory para crear una instancia de ProductoEscaneado desde un mapa
  /// @param map Mapa con los datos del producto escaneado
  /// @return Nueva instancia de ProductoEscaneado
  factory ProductoEscaneado.fromMap(Map<String, dynamic> map) {
    return ProductoEscaneado(
      map['serialnumber'] ?? '',
    );
  }
}
