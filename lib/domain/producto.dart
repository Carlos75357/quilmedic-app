class Producto {
  String numerodeproducto; // el id
  String? descripcion;
  String codigoalmacen;
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
}
