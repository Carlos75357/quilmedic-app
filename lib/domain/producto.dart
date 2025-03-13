class Producto {
  int numproducto; // el id
  String? descripcion;
  int codigoalmacen;
  String? ubicacion;
  int numerolote;
  String? descripcionlote;
  int numerodeproducto; // codigo referenciado al producto
  String descripcion1;
  int codigoalmacen1;
  int serie;
  DateTime fechacaducidad;

  Producto(
    this.numproducto,
    this.descripcion,
    this.codigoalmacen,
    this.ubicacion,
    this.numerolote,
    this.descripcionlote,
    this.numerodeproducto,
    this.descripcion1,
    this.codigoalmacen1,
    this.serie,
    this.fechacaducidad,
  );

  Map<String, dynamic> toMap() {
    return {
      'numproducto': numproducto,
      'descripcion': descripcion,
      'codigoalmacen': codigoalmacen,
      'ubicacion': ubicacion,
      'numerolote': numerolote,
      'descripcionlote': descripcionlote,
      'numerodeproducto': numerodeproducto,
      'descripcion1': descripcion1,
      'codigoalmacen1': codigoalmacen1,
      'serie': serie,
      'fechacaducidad': fechacaducidad.toIso8601String(),
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      map['numproducto'] ?? 0,
      map['descripcion'],
      map['codigoalmacen'] ?? 0,
      map['ubicacion'],
      map['numerolote'] ?? 0,
      map['descripcionlote'],
      map['numerodeproducto'] ?? 0,
      map['descripcion1'] ?? 'Sin descripción',
      map['codigoalmacen1'] ?? 0,
      map['serie'] ?? 0,
      DateTime.parse(map['fechacaducidad']),
    );
  }
}
