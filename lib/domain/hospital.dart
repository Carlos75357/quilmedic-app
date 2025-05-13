class Hospital {
  int id;
  String description;

  Hospital(this.id, this.description);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      json['id'] ?? 0,
      json['description'] ?? '',
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hospital && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
