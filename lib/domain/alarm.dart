/// Clase que representa una alarma en el sistema.
/// Las alarmas definen reglas de colores para fechas de caducidad y niveles de stock
/// según lo almacenado en la base de datos.
class Alarm {
  /// Identificador único de la alarma
  int? id;
  /// Color asociado a la alarma (grey, red, orange, yellow, green, lightgreen)
  String? color;
  /// Condición de la alarma (<=1, <30, <180, <365, >365, etc.)
  String? condition;
  /// Tipo de alarma ('date' para fechas de caducidad o 'stock' para niveles de inventario)
  String? type;
  /// ID del producto asociado a la alarma (para alarmas específicas por producto)
  int? productId;
  /// ID de la ubicación asociada a la alarma (opcional)
  int? locationId;

  /// Constructor de la clase Alarm
  /// @param [id] Identificador único de la alarma
  /// @param [color] Color asociado a la alarma
  /// @param [condition] Condición de la alarma
  /// @param [type] Tipo de alarma ('date' o 'stock')
  /// @param [productId] ID del producto asociado (opcional)
  /// @param [locationId] ID de la ubicación asociada (opcional)
  Alarm({
    this.id,
    this.color,
    this.condition,
    this.type,
    this.productId,
    this.locationId,
  });

  /// Constructor factory para crear una instancia de Alarm desde un mapa JSON
  /// proveniente de la API
  /// @param [json] Mapa con los datos en formato JSON
  /// @return Nueva instancia de [Alarm]
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      color: json['color'],
      condition: json['condition'],
      type: json['type'],
      productId: json['products']?[0]['id'],
      locationId: json['locations'] != null && json['locations'].isNotEmpty ? json['locations'][0]['id'] : null,
    );
  }

  /// Convierte la instancia actual a un mapa JSON para enviar a la API
  /// @return [Map] Mapa con los datos de la alarma en formato JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'condition': condition,
      'type': type,
      'productId': productId,
      'locationId': locationId,
    };
  }

  /// Constructor factory para crear una instancia de Alarm desde un mapa
  /// almacenado localmente
  /// @param [map] Mapa con los datos de la alarma
  /// @return Nueva instancia de [Alarm]
  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      color: map['color'],
      condition: map['condition'],
      type: map['type'],
      productId: map['products']?[0]['id'] ?? map['productId'],
      locationId: map['locations']?[0]['id'] ?? map['locationId'],
    );
  }

  /// Convierte la instancia actual a un mapa para almacenamiento local
  /// @return [Map] Mapa con los datos de la alarma
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'color': color,
      'condition': condition,
      'type': type,
      'productId': productId,
      'locationId': locationId,
    };
  }
}
