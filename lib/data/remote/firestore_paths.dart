class FirestorePaths {
  // Private constructor to prevent instantiation
  FirestorePaths._();

  // ==================== USERS COLLECTION ====================
  
  /// Root users collection
  static const String users = 'users';
  
  /// Get user document path
  static String user(String userId) => '$users/$userId';
  
  // ==================== TERMS (under users) ====================
  
  /// Get terms collection path for a user
  static String terms(String userId) => '${user(userId)}/terms';
  
  /// Get specific term document path
  static String term(String userId, String termId) => 
      '${terms(userId)}/$termId';
  
  // ==================== SUBJECTS (under terms) ====================
  
  /// Get subjects collection path for a term
  static String subjects(String userId, String termId) => 
      '${term(userId, termId)}/subjects';
  
  /// Get specific subject document path
  static String subject(String userId, String termId, String subjectId) => 
      '${subjects(userId, termId)}/$subjectId';
  
  // ==================== ASSIGNMENTS (under subjects) ====================
  
  /// Get assignments collection path for a subject
  static String assignments(String userId, String termId, String subjectId) => 
      '${subject(userId, termId, subjectId)}/assignments';
  
  /// Get specific assignment document path
  static String assignment(String userId, String termId, String subjectId, String assignmentId) => 
      '${assignments(userId, termId, subjectId)}/$assignmentId';
  
  // ==================== CLASS TEMPLATES (under subjects) ====================
  
  /// Get class templates collection path for a subject
  static String classTemplates(String userId, String termId, String subjectId) => 
      '${subject(userId, termId, subjectId)}/classTemplates';
  
  /// Get specific class template document path
  static String classTemplate(String userId, String termId, String subjectId, String templateId) => 
      '${classTemplates(userId, termId, subjectId)}/$templateId';
  
  // ==================== CLASS EXCEPTIONS (under subjects) ====================
  
  /// Get class exceptions collection path for a subject
  static String classExceptions(String userId, String termId, String subjectId) => 
      '${subject(userId, termId, subjectId)}/classExceptions';
  
  /// Get specific class exception document path
  static String classException(String userId, String termId, String subjectId, String exceptionId) => 
      '${classExceptions(userId, termId, subjectId)}/$exceptionId';
  
  // ==================== EXAMS (under subjects) ====================
  
  /// Get exams collection path for a subject
  static String exams(String userId, String termId, String subjectId) => 
      '${subject(userId, termId, subjectId)}/exams';
  
  /// Get specific exam document path
  static String exam(String userId, String termId, String subjectId, String examId) => 
      '${exams(userId, termId, subjectId)}/$examId';
  
  // ==================== TEACHERS (under users) ====================
  
  /// Get teachers collection path for a user
  static String teachers(String userId) => '${user(userId)}/teachers';
  
  /// Get specific teacher document path
  static String teacher(String userId, String teacherId) => 
      '${teachers(userId)}/$teacherId';
  
  // ==================== HOLIDAYS (under users) ====================
  
  /// Get holidays collection path for a user
  static String holidays(String userId) => '${user(userId)}/holidays';
  
  /// Get specific holiday document path
  static String holiday(String userId, String holidayId) => 
      '${holidays(userId)}/$holidayId';
  
  // ==================== SETTINGS (under users) ====================
  
  /// Get settings collection path for a user
  static String settings(String userId) => '${user(userId)}/settings';
  
  /// Get the single preferences document path
  /// Note: settings uses a fixed document ID "preferences"
  static String preferences(String userId) => '${settings(userId)}/preferences';
  
  // ==================== GROUPS COLLECTION ====================
  
  /// Root groups collection (separate from users)
  static const String groups = 'groups';
  
  /// Get specific group document path
  static String group(String groupId) => '$groups/$groupId';
  
  // ==================== WEEKLY AVAILABILITY (under groups) ====================
  
  /// Get weekly availability collection path for a group
  static String weeklyAvailability(String groupId) => 
      '${group(groupId)}/weeklyAvailability';
  
  /// Get specific week availability document path
  /// Document ID is the week identifier (e.g., '2025-W02')
  static String weekAvailability(String groupId, String weekIdentifier) => 
      '${weeklyAvailability(groupId)}/$weekIdentifier';
}