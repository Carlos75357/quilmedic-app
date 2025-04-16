class Producto {
  String productcode; // el id
  String? description;
  int numerolote;
  int locationid;
  String serialnumber;
  DateTime expirationdate;
  int stock;

  Producto(
    this.productcode,
    this.description,
    this.numerolote,
    this.locationid,
    this.serialnumber,
    this.expirationdate,
    this.stock,
  );

  Map<String, dynamic> toMap() {
    return {
      'productcode': productcode,
      'description': description,
      'numerolote': numerolote,
      'locationid': locationid,
      'serialnumber': serialnumber,
      'expirationdate': expirationdate,
      'stock': stock,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      map['productcode'] ?? 0,
      map['description'],
      map['numerolote'] ?? 0,
      map['locationid'] ?? 0,
      map['serialnumber'] ?? 0,
      DateTime.parse(map['expirationdate']),
      map['stock'] ?? 1,
    );
  }

  factory Producto.fromApiMap(Map<String, dynamic> mapa) {
    try {
      return Producto(
        mapa['product_code'] ?? '0',
        mapa['description'],
        mapa['numerolote'] ?? 0,
        mapa['location_id'] ?? 0,
        mapa['serial_number'] ?? '',
        mapa['expiration_date'] != null
            ? DateTime.parse(mapa['expiration_date'])
            : DateTime.now(),
        int.tryParse(mapa['stock']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
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
