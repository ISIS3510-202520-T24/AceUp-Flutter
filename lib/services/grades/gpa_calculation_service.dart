import '../../data/local/database/app_database.dart';

/// Service for calculating GPA values from assignments and subject data
/// 
/// Calculations follow the schema:
/// - Subject grade = Σ(category average × category weight) for all weight categories
/// - Term GPA = Σ(subject grade × credits) / Σ(credits)
/// - Overall GPA = Σ(term GPA × term credits) / Σ(all term credits)
class GpaCalculationService {
  final AppDatabase _db;

  GpaCalculationService({required AppDatabase database}) : _db = database;

  // ==================== SUBJECT GRADE ====================

  /// Calculate current grade for a subject based on graded assignments
  /// Returns null if no graded assignments exist
  Future<double?> calculateSubjectGrade(String subjectId) async {
    try {
      // Get subject details to check for final grade override
      final subject = await _db.academicDao.getSubjectDetailById(subjectId);
      if (subject == null) return null;

      // If using final grade override, return that value
      if (subject.useFinalGradeOverride && subject.finalGrade != null) {
        return subject.finalGrade;
      }

      // Get all graded assignments for this subject
      final assignments = await _db.assignmentDao.getAssignmentsForSubject(subjectId);
      final gradedAssignments = assignments.where((a) => a.isGraded && a.grade > 0).toList();

      if (gradedAssignments.isEmpty) return null;

      // Parse weight categories from JSON
      // Note: In a real implementation, you'd parse weightCategoriesJson
      // For now, calculate simple weighted average
      double totalWeightedGrade = 0.0;
      double totalWeight = 0.0;

      for (final assignment in gradedAssignments) {
        totalWeightedGrade += assignment.grade * assignment.weight;
        totalWeight += assignment.weight;
      }

      if (totalWeight == 0) return null;

      // Return weighted average (0-100 scale)
      return totalWeightedGrade / totalWeight;
    } catch (e) {
      print('❌ Error calculating subject grade for $subjectId: $e');
      return null;
    }
  }

  // ==================== TERM GPA ====================

  /// Calculate GPA for a specific term
  /// Returns null if no subjects have grades
  Future<double?> calculateTermGpa(String termId, {String? gradingScale}) async {
    try {
      // Get all subjects for this term
      final subjects = await _db.academicDao.getSubjectsForTerm(termId);
      
      if (subjects.isEmpty) return null;

      double totalWeightedGrade = 0.0;
      int totalCredits = 0;

      for (final subject in subjects) {
        // Calculate or get subject grade
        final subjectGrade = await calculateSubjectGrade(subject.id);
        
        // Skip subjects without grades
        if (subjectGrade == null) continue;

        // Convert percentage grade to GPA scale (default: 0-5.0 scale)
        final gpaValue = _convertToGpaScale(subjectGrade, gradingScale ?? 'percentage');
        
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
      final terms = await _db.academicDao.getAllTermsForUser(userId);
      
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
      final subjects = await _db.academicDao.getSubjectsForTerm(termId);
      return subjects.fold<int>(0, (sum, subject) => sum + subject.credits);
    } catch (e) {
      print('❌ Error getting term credits: $e');
      return 0;
    }
  }

  /// Get total credits across all terms for a user
  Future<int> getTotalCredits(String userId) async {
    try {
      final terms = await _db.academicDao.getAllTermsForUser(userId);
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
}