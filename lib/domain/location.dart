class Location {
  int id;
  String name;
  int storeId;

  Location({required this.id, required this.name, required this.storeId});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      storeId: json['store_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'store_id': storeId};
  }
}
