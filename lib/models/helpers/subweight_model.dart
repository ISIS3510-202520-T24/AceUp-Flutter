class Subweight {
  final String id;
  final String name;
  final double percentage;

  Subweight({
    required this.id,
    required this.name,
    required this.percentage,
  });

  factory Subweight.fromJson(Map<String, dynamic> json) {
    return Subweight(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'percentage': percentage,
    };
  }

  Subweight copyWith({
    String? id,
    String? name,
    double? percentage,
  }) {
    return Subweight(
      id: id ?? this.id,
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
    );
  }
}