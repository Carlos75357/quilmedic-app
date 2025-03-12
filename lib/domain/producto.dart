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
    this.fechacaducidad
  );
}