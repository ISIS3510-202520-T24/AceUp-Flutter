import '../../data/repositories/academic_repository.dart';
import '../../models/planner/subject_model.dart';
import '../../models/assignments/assignment_model.dart';

/// Service for calculating GPA values from assignments and subject data
///
/// Calculations follow the schema:
/// - Subject grade = Σ(weight category average × weight percentage) for all weight categories
/// - Category average = average of all graded assignments in that weight category
/// - Term GPA = Σ(subject grade × credits) / Σ(credits)
/// - Overall GPA = Σ(term GPA × term credits) / Σ(all term credits)
class GpaCalculationService {
  final AcademicRepository _repository;

  GpaCalculationService({required AcademicRepository repository})
      : _repository = repository;

  // ==================== SUBJECT GRADE ====================

  /// Calculate current grade for a subject based on graded assignments
  /// Returns null if no graded assignments exist
  Future<double?> calculateSubjectGrade(String subjectId) async {
    try {
      // Get subject details to check for final grade override
      final subject = await _repository.getSubjectById(subjectId);
      if (subject == null) return null;

      // If using final grade override, return that value
      if (subject.useFinalGradeOverride && subject.finalGrade != null) {
        return subject.finalGrade;
      }

      // Get all graded assignments for this subject
      final assignments = await _repository.getAssignmentsForSubject(subjectId);
      final gradedAssignments = assignments
          .where((a) => a.isGraded && a.grade != null && a.grade! > 0)
          .toList();

      if (gradedAssignments.isEmpty) return null;

      // Group assignments by weight category (weightId)
      final assignmentsByWeight = <String, List<Assignment>>{};
      for (final assignment in gradedAssignments) {
        if (assignment.weightId != null) {
          assignmentsByWeight.putIfAbsent(assignment.weightId!, () => [])
              .add(assignment);
        }
      }

      if (assignmentsByWeight.isEmpty) return null;

      // Calculate weighted grade based on weight categories
      double totalWeightedGrade = 0.0;
      double totalPercentage = 0.0;

      for (final entry in assignmentsByWeight.entries) {
        final weightId = entry.key;
        final assignmentsInCategory = entry.value;

        // Find the weight/subweight percentage
        final weightPercentage = _findWeightPercentage(subject, weightId);
        if (weightPercentage == null) continue;

        // Calculate average grade for this category
        final categoryAverage = assignmentsInCategory
            .map((a) => a.grade!)
            .reduce((a, b) => a + b) / assignmentsInCategory.length;

        // Add to weighted total
        totalWeightedGrade += categoryAverage * (weightPercentage / 100.0);
        totalPercentage += weightPercentage;
      }

      if (totalPercentage == 0) return null;

      // Normalize if total percentage doesn't equal 100
      // This handles cases where not all weight categories have assignments yet
      if (totalPercentage < 100) {
        totalWeightedGrade = (totalWeightedGrade / totalPercentage) * 100.0;
      }

      // Return weighted grade (0-100 scale)
      return totalWeightedGrade;
    } catch (e) {
      print('❌ Error calculating subject grade for $subjectId: $e');
      return null;
    }
  }

  /// Find the percentage for a weight or subweight by ID
  double? _findWeightPercentage(Subject subject, String weightId) {
    // Check if it's a top-level weight
    for (final weight in subject.weights) {
      if (weight.id == weightId) {
        return weight.percentage;
      }

      // Check if it's a subweight
      for (final subweight in weight.subweights) {
        if (subweight.id == weightId) {
          return subweight.percentage;
        }
      }
    }

    return null;
  }

  // ==================== WEIGHT CATEGORY BREAKDOWN ====================

  /// Get detailed breakdown of grades by weight category for a subject
  /// Useful for displaying grade breakdown in UI
  Future<Map<String, CategoryGrade>> getSubjectGradeBreakdown(String subjectId) async {
    try {
      final subject = await _repository.getSubjectById(subjectId);
      if (subject == null) return {};

      final assignments = await _repository.getAssignmentsForSubject(subjectId);
      final gradedAssignments = assignments
          .where((a) => a.isGraded && a.grade != null && a.grade! > 0)
          .toList();

      final breakdown = <String, CategoryGrade>{};

      // Group by weight
      for (final weight in subject.weights) {
        // Top-level weight
        final weightAssignments = gradedAssignments
            .where((a) => a.weightId == weight.id)
            .toList();

        if (weightAssignments.isNotEmpty) {
          final average = weightAssignments
              .map((a) => a.grade!)
              .reduce((a, b) => a + b) / weightAssignments.length;

          breakdown[weight.id] = CategoryGrade(
            categoryName: weight.name,
            categoryPercentage: weight.percentage,
            categoryAverage: average,
            assignmentCount: weightAssignments.length,
            isSubweight: false,
          );
        }

        // Subweights
        for (final subweight in weight.subweights) {
          final subweightAssignments = gradedAssignments
              .where((a) => a.weightId == subweight.id)
              .toList();

          if (subweightAssignments.isNotEmpty) {
            final average = subweightAssignments
                .map((a) => a.grade!)
                .reduce((a, b) => a + b) / subweightAssignments.length;

            breakdown[subweight.id] = CategoryGrade(
              categoryName: '${weight.name} > ${subweight.name}',
              categoryPercentage: subweight.percentage,
              categoryAverage: average,
              assignmentCount: subweightAssignments.length,
              isSubweight: true,
              parentWeightName: weight.name,
            );
          }
        }
      }

      return breakdown;
    } catch (e) {
      print('❌ Error getting subject grade breakdown: $e');
      return {};
    }
  }

  // ==================== TERM GPA ====================

  /// Calculate GPA for a specific term
  /// Returns null if no subjects have grades
  Future<double?> calculateTermGpa(String termId, {String? gradingScale}) async {
    try {
      // Get all subjects for this term
      final subjects = await _repository.getSubjectsForTerm(termId);

      if (subjects.isEmpty) return null;

      double totalWeightedGrade = 0.0;
      int totalCredits = 0;

      for (final subject in subjects) {
        // Calculate or get subject grade
        final subjectGrade = await calculateSubjectGrade(subject.id);

        // Skip subjects without grades
        if (subjectGrade == null) continue;

        // Subject grades are already on the correct scale:
        // - If calculated from assignments: 0-100 percentage scale
        // - If using final grade override: user's input scale (0-5.0 Colombian scale)
        // We need to convert percentage grades (0-100) to GPA scale (0-5.0)
        // But final grade overrides are already on 5.0 scale, so check which one it is
        final isOverride = subject.useFinalGradeOverride && subject.finalGrade != null;
        final gpaValue = isOverride ? subjectGrade : _convertToGpaScale(subjectGrade, gradingScale ?? 'percentage');

        totalWeightedGrade += gpaValue * subject.credits;
        totalCredits += subject.credits;
      }

      if (totalCredits == 0) return null;

      // Return weighted GPA
      return totalWeightedGrade / totalCredits;
    } catch (e) {
      print('❌ Error calculating term GPA for $termId: $e');
      return null;
    }
  }

  // ==================== OVERALL GPA ====================

  /// Calculate overall GPA across all terms for a user
  /// Returns null if no terms have grades
  Future<double?> calculateOverallGpa(String userId, {String? gradingScale}) async {
    try {
      // Get all terms for user
      final terms = await _repository.getTermsForUser(userId);

      if (terms.isEmpty) return null;

      double totalWeightedGpa = 0.0;
      int totalCredits = 0;

      for (final term in terms) {
        // Calculate term GPA
        final termGpa = await calculateTermGpa(term.id, gradingScale: gradingScale);

        // Skip terms without grades
        if (termGpa == null) continue;

        // Get total credits for this term
        final termCredits = await _getTermTotalCredits(term.id);

        totalWeightedGpa += termGpa * termCredits;
        totalCredits += termCredits;
      }

      if (totalCredits == 0) return null;

      // Return overall weighted GPA
      return totalWeightedGpa / totalCredits;
    } catch (e) {
      print('❌ Error calculating overall GPA for user $userId: $e');
      return null;
    }
  }

  // ==================== TERM CREDITS ====================

  /// Get total credits for a term
  Future<int> getTermTotalCredits(String termId) async {
    return await _getTermTotalCredits(termId);
  }

  Future<int> _getTermTotalCredits(String termId) async {
    try {
      final subjects = await _repository.getSubjectsForTerm(termId);
      return subjects.fold<int>(0, (sum, subject) => sum + subject.credits);
    } catch (e) {
      print('❌ Error getting term credits: $e');
      return 0;
    }
  }

  /// Get total credits across all terms for a user
  Future<int> getTotalCredits(String userId) async {
    try {
      final terms = await _repository.getTermsForUser(userId);
      int total = 0;

      for (final term in terms) {
        total += await _getTermTotalCredits(term.id);
      }

      return total;
    } catch (e) {
      print('❌ Error getting total credits: $e');
      return 0;
    }
  }

  // ==================== SUBJECT STATISTICS ====================

  /// Get statistics for a subject including completion rate
  Future<SubjectStats> getSubjectStatistics(String subjectId) async {
    try {
      final subject = await _repository.getSubjectById(subjectId);
      if (subject == null) {
        return SubjectStats(
          totalAssignments: 0,
          completedAssignments: 0,
          gradedAssignments: 0,
          completionRate: 0.0,
          currentGrade: null,
        );
      }

      final assignments = await _repository.getAssignmentsForSubject(subjectId);
      final completed = assignments.where((a) => a.isCompleted).length;
      final graded = assignments.where((a) => a.isGraded && a.grade != null && a.grade! > 0).length;
      final currentGrade = await calculateSubjectGrade(subjectId);

      return SubjectStats(
        totalAssignments: assignments.length,
        completedAssignments: completed,
        gradedAssignments: graded,
        completionRate: assignments.isEmpty ? 0.0 : (completed / assignments.length) * 100.0,
        currentGrade: currentGrade,
      );
    } catch (e) {
      print('❌ Error getting subject statistics: $e');
      return SubjectStats(
        totalAssignments: 0,
        completedAssignments: 0,
        gradedAssignments: 0,
        completionRate: 0.0,
        currentGrade: null,
      );
    }
  }

  // ==================== CONVERSION HELPERS ====================

  /// Convert percentage grade (0-100) to GPA scale
  /// Default scale: 5.0 (Colombian standard)
  double _convertToGpaScale(double percentageGrade, String scaleType) {
    switch (scaleType) {
      case 'percentage':
        // Convert 0-100 to 0-5.0 scale
        return (percentageGrade / 100.0) * 5.0;

      case 'letter':
        // Convert to 4.0 scale (US standard)
        if (percentageGrade >= 90) return 4.0;
        if (percentageGrade >= 80) return 3.0;
        if (percentageGrade >= 70) return 2.0;
        if (percentageGrade >= 60) return 1.0;
        return 0.0;

      case 'points':
      default:
        // Direct conversion to 5.0 scale
        return (percentageGrade / 100.0) * 5.0;
    }
  }

  /// Convert GPA to display format
  String formatGpa(double? gpa) {
    if (gpa == null) return 'N/A';
    return gpa.toStringAsFixed(2);
  }

  /// Format percentage grade
  String formatPercentage(double? percentage) {
    if (percentage == null) return 'N/A';
    return '${percentage.toStringAsFixed(1)}%';
  }
}

// ==================== HELPER CLASSES ====================

/// Grade information for a weight category
class CategoryGrade {
  final String categoryName;
  final double categoryPercentage;
  final double categoryAverage;
  final int assignmentCount;
  final bool isSubweight;
  final String? parentWeightName;

  CategoryGrade({
    required this.categoryName,
    required this.categoryPercentage,
    required this.categoryAverage,
    required this.assignmentCount,
    required this.isSubweight,
    this.parentWeightName,
  });

  /// Contribution to overall grade
  double get contribution => categoryAverage * (categoryPercentage / 100.0);

  @override
  String toString() {
    return 'CategoryGrade(name: $categoryName, percentage: $categoryPercentage%, average: ${categoryAverage.toStringAsFixed(1)}, count: $assignmentCount)';
  }
}

/// Statistics for a subject
class SubjectStats {
  final int totalAssignments;
  final int completedAssignments;
  final int gradedAssignments;
  final double completionRate;
  final double? currentGrade;

  SubjectStats({
    required this.totalAssignments,
    required this.completedAssignments,
    required this.gradedAssignments,
    required this.completionRate,
    required this.currentGrade,
  });

  @override
  String toString() {
    return 'SubjectStats(total: $totalAssignments, completed: $completedAssignments, graded: $gradedAssignments, rate: ${completionRate.toStringAsFixed(1)}%, grade: ${currentGrade?.toStringAsFixed(1) ?? 'N/A'})';
  }
}
