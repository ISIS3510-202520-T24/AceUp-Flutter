import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/local/database/app_database.dart';
import '../../data/remote/firestore_paths.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../core/constants/enums.dart';

class InitialLoadService extends ChangeNotifier {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;

  bool _isLoading = false;
  double _progress = 0.0;
  String _currentTask = '';
  String? _error;

  bool get isLoading => _isLoading;
  double get progress => _progress;
  String get currentTask => _currentTask;
  String? get error => _error;

  InitialLoadService({
    required AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  /// Main entry point: Load ALL user data from Firebase at login
  Future<bool> performInitialLoad(String userId) async {
    if (_isLoading) {
      print('⚠️ Initial load already in progress');
      return false;
    }

    if (!_connectivity.isOnline) {
      print('⚠️ Cannot perform initial load: Device is offline');
      _error = 'No internet connection. Using cached data.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _progress = 0.0;
    _error = null;
    notifyListeners();

    print('🚀 ========== INITIAL DATA LOAD STARTED ==========');
    print('👤 User: $userId');

    final stopwatch = Stopwatch()..start();

    try {
      // Phase 1: Load User Profile (5%)
      await _loadUserProfile(userId);
      _updateProgress(0.05, 'User profile loaded');

      // Phase 2: Load Settings (10%)
      await _loadSettings(userId);
      _updateProgress(0.10, 'Settings loaded');

      // Phase 3: Load Teachers (15%)
      await _loadTeachers(userId);
      _updateProgress(0.15, 'Teachers loaded');

      // Phase 4: Load Holidays (20%)
      await _loadHolidays(userId);
      _updateProgress(0.20, 'Holidays loaded');

      // Phase 5: Load Terms and all nested data (70%)
      await _loadTermsWithNestedData(userId);
      _updateProgress(0.70, 'Academic data loaded');

      // Phase 6: Load Groups (90%)
      await _loadGroups(userId);
      _updateProgress(0.90, 'Groups loaded');

      // Phase 7: Finalize (100%)
      await _finalizeLoad(userId);
      _updateProgress(1.0, 'Complete');

      stopwatch.stop();
      print('✅ ========== INITIAL LOAD COMPLETE ==========');
      print('⏱️ Total time: ${stopwatch.elapsedMilliseconds}ms');

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e, stackTrace) {
      stopwatch.stop();
      print('❌ ========== INITIAL LOAD FAILED ==========');
      print('❌ Error: $e');
      print('📍 Stack trace: $stackTrace');

      _error = 'Failed to load data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== PHASE 1: USER PROFILE ====================

  Future<void> _loadUserProfile(String userId) async {
    _currentTask = 'Loading user profile...';
    notifyListeners();

    final userDoc = await _firestore.doc(FirestorePaths.user(userId)).get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      await _db.userDao.upsertUser(
        uid: userId,
        email: data['email'] ?? '',
        nickname: data['nickname'] ?? '',
        avatar: data['avatar'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      );
      print('✅ User profile loaded');
    } else {
      print('⚠️ User document not found, creating...');
    }
  }

  // ==================== PHASE 2: SETTINGS ====================

  Future<void> _loadSettings(String userId) async {
    _currentTask = 'Loading settings...';
    notifyListeners();

    final settingsDoc = await _firestore.doc(FirestorePaths.preferences(userId)).get();

    if (settingsDoc.exists) {
      final data = settingsDoc.data()!;
      
      // Parse grading scale
      final gradingScaleData = data['gradingScale'] as Map<String, dynamic>?;
      GradingScaleType? scaleType;
      if (gradingScaleData != null) {
        scaleType = GradingScaleType.values.firstWhere(
          (e) => e.name == gradingScaleData['type'],
          orElse: () => GradingScaleType.percentage,
        );
      }

      await _db.settingsDao.upsertSettings(
        userId: userId,
        defaultClassDuration: data['defaultClassDuration'] ?? 60,
        weekdays: List<int>.from(data['weekdays'] ?? [1, 2, 3, 4, 5]),
        gradingScaleType: scaleType?.name ?? 'percentage',
        gradingScaleConfig: gradingScaleData,
        holidayCountry: data['holidayCountry'] ?? 'CO',
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
      print('✅ Settings loaded');
    } else {
      print('⚠️ Settings not found, using defaults');
    }
  }

  // ==================== PHASE 3: TEACHERS ====================

  Future<void> _loadTeachers(String userId) async {
    _currentTask = 'Loading teachers...';
    notifyListeners();

    final teachersSnapshot = await _firestore
        .collection(FirestorePaths.teachers(userId))
        .get();

    int count = 0;
    for (final doc in teachersSnapshot.docs) {
      final data = doc.data();
      await _db.teacherDao.upsertTeacher(
        id: doc.id,
        userId: userId,
        name: data['name'] ?? '',
        position: data['position'],
        department: data['department'],
        affiliation: data['affiliation'],
        email: data['email'],
        phone: data['phone'],
        webPage: data['webPage'],
        officeHours: data['officeHours'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
      count++;
    }
    print('✅ Loaded $count teachers');
  }

  // ==================== PHASE 4: HOLIDAYS ====================

  Future<void> _loadHolidays(String userId) async {
    _currentTask = 'Loading holidays...';
    notifyListeners();

    final holidaysSnapshot = await _firestore
        .collection(FirestorePaths.holidays(userId))
        .get();

    int count = 0;
    for (final doc in holidaysSnapshot.docs) {
      final data = doc.data();
      await _db.holidayDao.upsertHoliday(
        id: doc.id,
        userId: userId,
        name: data['name'] ?? '',
        startDate: (data['startDate'] as Timestamp).toDate(),
        endDate: (data['endDate'] as Timestamp).toDate(),
        source: data['source'] ?? 'user',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
      count++;
    }
    print('✅ Loaded $count holidays');
  }

  // ==================== PHASE 5: TERMS WITH NESTED DATA ====================

  Future<void> _loadTermsWithNestedData(String userId) async {
    _currentTask = 'Loading academic data...';
    notifyListeners();

    final termsSnapshot = await _firestore
        .collection(FirestorePaths.terms(userId))
        .orderBy('startDate', descending: true)
        .get();

    print('📚 Found ${termsSnapshot.docs.length} terms');

    int termIndex = 0;
    for (final termDoc in termsSnapshot.docs) {
      final termData = termDoc.data();
      final termId = termDoc.id;

      // Save term
      await _db.termDao.upsertTerm(
        id: termId,
        userId: userId,
        name: termData['name'] ?? '',
        startDate: (termData['startDate'] as Timestamp).toDate(),
        endDate: (termData['endDate'] as Timestamp).toDate(),
        isActive: termData['isActive'] ?? false,
        createdAt: (termData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (termData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      // Load subjects for this term
      await _loadSubjectsForTerm(userId, termId);

      termIndex++;
      final termProgress = 0.20 + (0.50 * termIndex / termsSnapshot.docs.length);
      _updateProgress(termProgress, 'Loading term ${termIndex}/${termsSnapshot.docs.length}');
    }

    print('✅ Academic data loaded');
  }

  Future<void> _loadSubjectsForTerm(String userId, String termId) async {
    final subjectsSnapshot = await _firestore
        .collection(FirestorePaths.subjects(userId, termId))
        .get();

    for (final subjectDoc in subjectsSnapshot.docs) {
      final subjectData = subjectDoc.data();
      final subjectId = subjectDoc.id;

      // Save subject
      await _db.subjectDao.upsertSubject(
        id: subjectId,
        termId: termId,
        name: subjectData['name'] ?? '',
        color: subjectData['color'] ?? '#6B7280',
        credits: (subjectData['credits'] ?? 0).toDouble(),
        finalGrade: subjectData['finalGrade']?.toDouble(),
        useFinalGradeOverride: subjectData['useFinalGradeOverride'] ?? false,
        weights: subjectData['weights'],
        createdAt: (subjectData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (subjectData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      // Load nested data for this subject
      await Future.wait([
        _loadAssignments(userId, termId, subjectId),
        _loadClassTemplates(userId, termId, subjectId),
        _loadClassExceptions(userId, termId, subjectId),
        _loadExams(userId, termId, subjectId),
      ]);
    }
  }

  Future<void> _loadAssignments(String userId, String termId, String subjectId) async {
    final assignmentsSnapshot = await _firestore
        .collection(FirestorePaths.assignments(userId, termId, subjectId))
        .get();

    for (final doc in assignmentsSnapshot.docs) {
      final data = doc.data();
      await _db.assignmentDao.upsertAssignment(
        id: doc.id,
        subjectId: subjectId,
        title: data['title'] ?? '',
        description: data['description'],
        dueDate: (data['dueDate'] as Timestamp).toDate(),
        dueTime: data['dueTime'],
        weightId: data['weightId'],
        priority: data['priority'] ?? 'medium',
        isCompleted: data['isCompleted'] ?? false,
        completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
        isGraded: data['isGraded'] ?? false,
        grade: data['grade']?.toDouble(),
        alerts: data['alerts'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }
  }

  Future<void> _loadClassTemplates(String userId, String termId, String subjectId) async {
    final templatesSnapshot = await _firestore
        .collection(FirestorePaths.classTemplates(userId, termId, subjectId))
        .get();

    for (final doc in templatesSnapshot.docs) {
      final data = doc.data();
      await _db.classDao.upsertClassTemplate(
        id: doc.id,
        subjectId: subjectId,
        name: data['name'] ?? '',
        icon: data['icon'] ?? 'class',
        startDate: (data['startDate'] as Timestamp).toDate(),
        endDate: (data['endDate'] as Timestamp).toDate(),
        startTime: data['startTime'] ?? '08:00',
        endTime: data['endTime'] ?? '09:00',
        recurrence: data['recurrence'],
        building: data['building'],
        room: data['room'],
        teacherId: data['teacherId'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }
  }

  Future<void> _loadClassExceptions(String userId, String termId, String subjectId) async {
    final exceptionsSnapshot = await _firestore
        .collection(FirestorePaths.classExceptions(userId, termId, subjectId))
        .get();

    for (final doc in exceptionsSnapshot.docs) {
      final data = doc.data();
      await _db.classDao.upsertClassException(
        id: doc.id,
        classTemplateId: data['classTemplateId'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        isCancelled: data['isCancelled'] ?? false,
        notes: data['notes'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }
  }

  Future<void> _loadExams(String userId, String termId, String subjectId) async {
    final examsSnapshot = await _firestore
        .collection(FirestorePaths.exams(userId, termId, subjectId))
        .get();

    for (final doc in examsSnapshot.docs) {
      final data = doc.data();
      await _db.examDao.upsertExam(
        id: doc.id,
        subjectId: subjectId,
        name: data['name'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        startTime: data['startTime'] ?? '08:00',
        endTime: data['endTime'] ?? '10:00',
        weightId: data['weightId'],
        building: data['building'],
        room: data['room'],
        teacherId: data['teacherId'],
        isCompleted: data['isCompleted'] ?? false,
        completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
        isGraded: data['isGraded'] ?? false,
        grade: data['grade']?.toDouble(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }
  }

  // ==================== PHASE 6: GROUPS ====================

  Future<void> _loadGroups(String userId) async {
    _currentTask = 'Loading groups...';
    notifyListeners();

    // Get groups where user is owner
    final ownerGroupsSnapshot = await _firestore
        .collection(FirestorePaths.groups)
        .where('ownerId', isEqualTo: userId)
        .get();

    // Get all groups and filter by membership
    final allGroupsSnapshot = await _firestore
        .collection(FirestorePaths.groups)
        .get();

    final loadedGroupIds = <String>{};

    // Process owner groups first
    for (final doc in ownerGroupsSnapshot.docs) {
      await _saveGroupLocally(doc);
      loadedGroupIds.add(doc.id);
    }

    // Process member groups
    for (final doc in allGroupsSnapshot.docs) {
      if (loadedGroupIds.contains(doc.id)) continue;

      final members = List<Map<String, dynamic>>.from(
        doc.data()['members'] ?? [],
      );
      
      final isMember = members.any((m) => m['userId'] == userId);
      if (isMember) {
        await _saveGroupLocally(doc);
        loadedGroupIds.add(doc.id);
      }
    }

    print('✅ Loaded ${loadedGroupIds.length} groups');
  }

  Future<void> _saveGroupLocally(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    
    await _db.groupDao.upsertGroup(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      color: data['color'] ?? '#6B7280',
      ownerId: data['ownerId'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );

    // Save members
    final members = List<Map<String, dynamic>>.from(data['members'] ?? []);
    for (final member in members) {
      await _db.groupDao.upsertGroupMember(
        groupId: doc.id,
        userId: member['userId'] ?? '',
        nickname: member['nickname'] ?? '',
        joinedAt: (member['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }
  }

  // ==================== PHASE 7: FINALIZE ====================

  Future<void> _finalizeLoad(String userId) async {
    _currentTask = 'Finalizing...';
    notifyListeners();

    // Clear any stale sync operations for this user
    await _db.syncDao.clearCompletedOperations();

    // Update last sync timestamp
    await _db.userDao.updateLastLogin(userId, DateTime.now());

    print('✅ Initial load finalized');
  }

  // ==================== HELPERS ====================

  void _updateProgress(double progress, String task) {
    _progress = progress;
    _currentTask = task;
    notifyListeners();
    print('📊 Progress: ${(progress * 100).toStringAsFixed(0)}% - $task');
  }
}