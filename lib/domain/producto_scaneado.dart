class ProductoEscaneado {
  final int id;
  final int serie;

  ProductoEscaneado(
    this.id,
    this.serie,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serie': serie,
    };
  }

  factory ProductoEscaneado.fromMap(Map<String, dynamic> map) {
    return ProductoEscaneado(
      map['id'] ?? 0,
      map['serie'] ?? 0
    );
  }
}
