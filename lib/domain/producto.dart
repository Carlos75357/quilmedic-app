class Producto {
  int id;
  String productcode; // el id
  String? description;
  int numerolote;
  int locationid;
  String serialnumber;
  DateTime expirationdate;
  int stock;
  int? minStock; // Stock mínimo esperado

  Producto(
    this.id,
    this.productcode,
    this.description,
    this.numerolote,
    this.locationid,
    this.serialnumber,
    this.expirationdate,
    this.stock, {
    this.minStock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productcode': productcode,
      'description': description,
      'numerolote': numerolote,
      'locationid': locationid,
      'serialnumber': serialnumber,
      'expirationdate': expirationdate,
      'stock': stock,
      'minStock': minStock,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      map['id'] ?? 0,
      map['productcode'] ?? 0,
      map['description'],
      map['numerolote'] ?? 0,
      map['locationid'] ?? 0,
      map['serialnumber'] ?? 0,
      DateTime.parse(map['expirationdate']),
      map['stock'] ?? 1,
      minStock: map['minStock'],
    );
  }

  factory Producto.fromApiMap(Map<String, dynamic> map) {
    try {
      return Producto(
        map['product_model_id'] ?? 0,
        map['product_code'] ?? '0',
        map['description'],
        map['numerolote'] ?? 0,
        map['location_id'] ?? 0,
        map['serial_number'] ?? '',
        map['expiration_date'] != null
            ? DateTime.parse(map['expiration_date'])
            : DateTime.now(),
        int.tryParse(map['stock']?.toString() ?? '0') ?? 0,
        minStock: int.tryParse(map['min_stock']?.toString() ?? ''),
      );
    } catch (e) {
      return Producto(
        0,
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
