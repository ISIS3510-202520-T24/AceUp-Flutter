import 'package:cloud_firestore/cloud_firestore.dart';

/// Subject (Materia académica) con soporte para cálculo de GPA
/// 
/// **Business Question 3.1**: Este modelo soporta el tracking de completitud
/// de datos necesarios para el cálculo automático de GPA.
/// 
/// Campos requeridos para GPA:
/// - `credits`: Créditos de la materia (1-9)
/// - Assignments con weights que sumen 100%
class Subject {
  final String id;
  final String name;
  final String? code;
  final int credits; // ✅ NUEVO: Requerido para GPA ponderado
  final String termId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Metadata para análisis (BQ 3.1)
  final bool hasCompleteDataForGPA; // Calculado en el cliente
  final DateTime? dataCompletedAt; // Cuando se completaron todos los campos

  Subject({
    required this.id,
    required this.name,
    this.code,
    required this.credits,
    required this.termId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.hasCompleteDataForGPA = false,
    this.dataCompletedAt,
  });

  /// Factory desde Firestore
  factory Subject.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    final credits = data['credits'] as int? ?? 0;
    final hasCompleteData = data['hasCompleteDataForGPA'] as bool? ?? false;
    
    return Subject(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Subject',
      code: data['code'],
      credits: credits,
      termId: data['termId'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      hasCompleteDataForGPA: hasCompleteData,
      dataCompletedAt: (data['dataCompletedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'credits': credits,
      'termId': termId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'hasCompleteDataForGPA': hasCompleteDataForGPA,
      'dataCompletedAt': dataCompletedAt != null 
        ? Timestamp.fromDate(dataCompletedAt!) 
        : null,
    };
  }

  /// Verifica si el subject tiene los datos mínimos para GPA
  /// 
  /// Criterios:
  /// 1. Credits > 0 (definidos)
  /// 2. Al menos 1 assignment con grade y weight
  bool get isReadyForGPA => credits > 0;

  /// Copia con modificaciones
  Subject copyWith({
    String? id,
    String? name,
    String? code,
    int? credits,
    String? termId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasCompleteDataForGPA,
    DateTime? dataCompletedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      credits: credits ?? this.credits,
      termId: termId ?? this.termId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasCompleteDataForGPA: hasCompleteDataForGPA ?? this.hasCompleteDataForGPA,
      dataCompletedAt: dataCompletedAt ?? this.dataCompletedAt,
    );
  }

  @override
  String toString() {
    return 'Subject(id: $id, name: $name, code: $code, credits: $credits, '
           'hasCompleteDataForGPA: $hasCompleteDataForGPA)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Subject &&
      other.id == id &&
      other.name == name &&
      other.code == code &&
      other.credits == credits &&
      other.termId == termId &&
      other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      code.hashCode ^
      credits.hashCode ^
      termId.hashCode ^
      userId.hashCode;
  }
}
