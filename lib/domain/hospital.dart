/// Clase que representa un hospital o centro médico en el sistema.
/// Contiene información básica del hospital como su identificador y descripción.
class Hospital {
  /// Identificador único del hospital
  int id;
  /// Nombre o descripción del hospital
  String description;

  /// Constructor de la clase Hospital
  /// @param [id] Identificador único del hospital
  /// @param [description] Nombre o descripción del hospital
  Hospital(this.id, this.description);

  /// Convierte la instancia actual a un mapa JSON para enviar a la API
  /// @return [Map] Mapa con los datos del hospital en formato JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }

  /// Constructor factory para crear una instancia de Hospital desde un mapa JSON
  /// proveniente de la API
  /// @param [json] Mapa con los datos en formato JSON
  /// @return Nueva instancia de [Hospital]
  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      json['id'] ?? 0,
      json['description'] ?? '',
    );
  }
  
  /// Sobrescribe el operador de igualdad para comparar hospitales por su ID
  /// @param [other] Objeto a comparar
  /// @return [bool] true si los hospitales tienen el mismo ID, false en caso contrario
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hospital && other.id == id;
  }

  /// Sobrescribe el cálculo del código hash basado en el ID del hospital
  /// @return [int] Código hash del hospital
  @override
  int get hashCode => id.hashCode;
}
