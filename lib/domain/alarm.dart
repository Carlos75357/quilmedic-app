class Alarm {
  int? id;
  String? color;
  String? condition;
  String? type;
  int? productId;

  Alarm({
    this.id,
    this.color,
    this.condition,
    this.type,
    this.productId
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      color: json['color'],
      condition: json['condition'],
      type: json['type'],
      productId: json['productId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'condition': condition,
      'type': type,
      'productId': productId
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      color: map['color'],
      condition: map['condition'],
      type: map['type'],
      productId: map['productId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'color': color,
      'condition': condition,
      'type': type,
      'productId': productId
    };
  }
}
