/// Clase que representa una ubicación o área dentro de un hospital.
/// Contiene información sobre la ubicación como su identificador, nombre y el hospital al que pertenece.
class Location {
  /// Identificador único de la ubicación
  int id;
  /// Nombre o descripción de la ubicación
  String name;
  /// Identificador del hospital al que pertenece esta ubicación
  int storeId;

  /// Constructor de la clase Location
  /// @param [id] Identificador único de la ubicación
  /// @param [name] Nombre o descripción de la ubicación
  /// @param [storeId] Identificador del hospital al que pertenece
  Location({required this.id, required this.name, required this.storeId});

  /// Constructor factory para crear una instancia de Location desde un mapa JSON
  /// proveniente de la API
  /// @param [json] Mapa con los datos en formato JSON
  /// @return Nueva instancia de [Location]
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      storeId: json['store_id'],
    );
  }

  /// Convierte la instancia actual a un mapa JSON para enviar a la API
  /// @return [Map] Mapa con los datos de la ubicación en formato JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'store_id': storeId};
  }
}
