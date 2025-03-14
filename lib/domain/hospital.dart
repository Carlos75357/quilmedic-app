class Hospital {
  int codigo;
  String nombre;

  Hospital(this.codigo, this.nombre);

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
    };
  }

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      json['codigo'] ?? 0,
      json['nombre'] ?? '',
    );
  }
}
