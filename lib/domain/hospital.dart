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
    final id = json['id'];
    int hospitalId;

    if (id is int) {
      hospitalId = id;
    } else if (id is String) {
      try {
        hospitalId = int.parse(id);
      } catch (_) {
        hospitalId = 0;
      }
    } else {
      hospitalId = 0;
    }

    return Hospital(
      hospitalId,
      json['nombre'] ?? '',
    );
  }
}
