class Producto {
  String productcode; // el id
  String? description;
  int storeid;
  int numerolote;
  String serialnumber;
  DateTime expirationdate;
  int stock;

  Producto(
    this.productcode,
    this.description,
    this.storeid,
    this.numerolote,
    this.serialnumber,
    this.expirationdate,
    this.stock,
  );

  Map<String, dynamic> toMap() {
    return {
      'productcode': productcode,
      'description': description,
      'storeid': storeid,
      'numerolote': numerolote,
      'serialnumber': serialnumber,
      'expirationdate': expirationdate,
      'stock': stock,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      map['productcode'] ?? 0,
      map['description'],
      map['storeid'] ?? 0,
      map['numerolote'] ?? 0,
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
