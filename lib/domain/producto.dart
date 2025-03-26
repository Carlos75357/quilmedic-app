class Producto {
  String numerodeproducto; // el id
  String? descripcion;
  int codigoalmacen;
  int numerolote;
  String serie;
  DateTime fechacaducidad;
  int cantidad;

  Producto(
    this.numerodeproducto,
    this.descripcion,
    this.codigoalmacen,
    this.numerolote,
    this.serie,
    this.fechacaducidad,
    this.cantidad,
  );

  Map<String, dynamic> toMap() {
    return {
      'numerodeproducto': numerodeproducto,
      'descripcion': descripcion,
      'codigoalmacen': codigoalmacen,
      'numerolote': numerolote,
      'serie': serie,
      'fechacaducidad': fechacaducidad,
      'cantidad': cantidad,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      map['numerodeproducto'] ?? 0,
      map['descripcion'],
      map['codigoalmacen'] ?? 0,
      map['numerolote'] ?? 0,
      map['serie'] ?? 0,
      DateTime.parse(map['fechacaducidad']),
      map['cantidad'] ?? 1,
    );
  }

  factory Producto.fromApiMap(Map<String, dynamic> mapa) {
    try {
      return Producto(
        mapa['product_code'] ?? '0',
        mapa['description'],
        mapa['store_id'] ?? 0,
        mapa['numerolote'] ?? 0,
        mapa['serial_number'] ?? '',
        mapa['expiration_date'] != null
            ? DateTime.parse(mapa['expiration_date'])
            : DateTime.now(),
        int.tryParse(mapa['stock']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
      print('Error al convertir mapa a Producto: $e');
      return Producto(
        '0',
        'Error al procesar producto',
        0,
        0,
        '',
        DateTime.now(),
        0,
      );
    }
  }
}
