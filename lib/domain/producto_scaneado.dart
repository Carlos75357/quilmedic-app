class ProductoEscaneado {
  final String serialnumber;

  ProductoEscaneado(this.serialnumber);

  Map<String, dynamic> toMap() {
    return {
      'serialnumber': serialnumber,
    };
  }

  factory ProductoEscaneado.fromMap(Map<String, dynamic> map) {
    return ProductoEscaneado(
      map['serialnumber'] ?? '',
    );
  }
}
