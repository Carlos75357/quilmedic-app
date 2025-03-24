class Alarma {
  int id;
  String color;
  String condition;

  Alarma({
    required this.id,
    required this.color,
    required this.condition,
  });

  factory Alarma.fromJson(Map<String, dynamic> json) {
    return Alarma(
      id: json['id'],
      color: json['color'],
      condition: json['condition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'condition': condition
    };
  }
}
