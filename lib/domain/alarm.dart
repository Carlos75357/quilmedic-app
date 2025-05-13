class Alarm {
  int? id;
  String? color;
  String? condition;
  String? type;
  int? productId;
  int? locationId;

  Alarm({
    this.id,
    this.color,
    this.condition,
    this.type,
    this.productId,
    this.locationId,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      color: json['color'],
      condition: json['condition'],
      type: json['type'],
      productId: json['products']?[0]['id'],
      locationId: json['locations'] != null && json['locations'].isNotEmpty ? json['locations'][0]['id'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'condition': condition,
      'type': type,
      'productId': productId,
      'locationId': locationId,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      color: map['color'],
      condition: map['condition'],
      type: map['type'],
      productId: map['products']?[0]['id'] ?? map['productId'],
      locationId: map['locations']?[0]['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'color': color,
      'condition': condition,
      'type': type,
      'productId': productId,
      'locationId': locationId,
    };
  }
}
