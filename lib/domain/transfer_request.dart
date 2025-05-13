class TransferRequest {
  final String email;
  final int fromStoreId;
  final int toStoreId;
  final int userId;
  final List<String> products; // Lista de serial_number de productos

  TransferRequest({
    required this.email,
    required this.fromStoreId,
    required this.toStoreId,
    required this.userId,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'from_store_id': fromStoreId,
      'to_store_id': toStoreId,
      'user_id': userId,
      'products': products,
    };
  }
}
