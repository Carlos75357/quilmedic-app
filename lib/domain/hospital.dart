class Hospital {
  int codigo;
  String nombre;

  Hospital(this.codigo, this.nombre);

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'nombre': nombre,
    };
  }

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      map['codigo'] ?? 0,
      map['nombre'] ?? '',
    );
  }
}
