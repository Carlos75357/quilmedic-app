class Hospital {
  int id;
  String nombre;

  Hospital(this.id, this.nombre);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      json['id'] ?? 0,
      json['nombre'] ?? '',
    );
  }
}
