class ProductoEscaneado {
  final String serie;

  ProductoEscaneado(this.serie);

  Map<String, dynamic> toMap() {
    return {
      'serie': serie,
    };
  }

  factory ProductoEscaneado.fromMap(Map<String, dynamic> map) {
    return ProductoEscaneado(
      map['serie'] ?? '',
    );
  }
}
