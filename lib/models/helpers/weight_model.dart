import 'dart:convert';
import 'subweight_model.dart';

class Weight {
  final String id;
  final String name;
  final double percentage;
  final List<Subweight> subweights;

  Weight({
    required this.id,
    required this.name,
    required this.percentage,
    this.subweights = const [],
  });

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
      subweights: (json['subweights'] as List<dynamic>?)
              ?.map((e) => Subweight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'percentage': percentage,
      'subweights': subweights.map((e) => e.toJson()).toList(),
    };
  }

  static List<Weight> fromJsonString(String jsonString) {
    if (jsonString.isEmpty || jsonString == '[]') return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => Weight.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String toJsonString(List<Weight> weights) {
    return json.encode(weights.map((e) => e.toJson()).toList());
  }

  Weight copyWith({
    String? id,
    String? name,
    double? percentage,
    List<Subweight>? subweights,
  }) {
    return Weight(
      id: id ?? this.id,
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      subweights: subweights ?? this.subweights,
    );
  }
}