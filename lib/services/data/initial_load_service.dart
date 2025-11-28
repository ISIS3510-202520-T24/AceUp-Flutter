import 'package:flutter/foundation.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/group_repository.dart';

/// Service to handle initial data load from Firebase upon user login
/// Implements offline-first pattern by fetching from Firebase and storing locally
class InitialLoadService extends ChangeNotifier {
  final UserRepository _userRepository;
  final AcademicRepository _academicRepository;
  final TeacherRepository _teacherRepository;
  final HolidayRepository _holidayRepository;
  final SettingsRepository _settingsRepository;
  final GroupRepository _groupRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _progress = 0.0;
  double get progress => _progress;

  String _currentStep = '';
  String get currentStep => _currentStep;

  String? _error;
  String? get error => _error;

  InitialLoadService({
    required UserRepository userRepository,
    required AcademicRepository academicRepository,
    required TeacherRepository teacherRepository,
    required HolidayRepository holidayRepository,
    required SettingsRepository settingsRepository,
    required GroupRepository groupRepository,
  })  : _userRepository = userRepository,
        _academicRepository = academicRepository,
        _teacherRepository = teacherRepository,
        _holidayRepository = holidayRepository,
        _settingsRepository = settingsRepository,
        _groupRepository = groupRepository;

  /// Load all user data from Firebase on initial login
  Future<void> loadAllDataFromFirebase(String userId) async {
    _isLoading = true;
    _progress = 0.0;
    _error = null;
    notifyListeners();

    try {
      print('🚀 ========== INITIAL DATA LOAD STARTED ==========');
      print('🚀 User ID: $userId');

      // Total steps for progress tracking
      const totalSteps = 10;
      var completedSteps = 0;

      // 1. Load user data
      _currentStep = 'Loading user profile...';
      notifyListeners();
      try {
        await _userRepository.fetchUserFromFirebase(userId);
        print('✅ User profile loaded');
      } catch (e) {
        print('⚠️  Error loading user profile: $e');
      }
      completedSteps++;
      _progress = completedSteps / totalSteps;
      notifyListeners();

      // 2. Load settings
      _currentStep = 'Loading settings...';
      notifyListeners();
      try {
        await _settingsRepository.fetchSettingsFromFirebase(userId);
        print('✅ Settings loaded');
      } catch (e) {
        print('⚠️  Error loading settings: $e');
        // Create default settings if not found
        await _settingsRepository.getOrCreateSettings(userId);
      }
      completedSteps++;
      _progress = completedSteps / totalSteps;
      notifyListeners();

      // 3. Load terms
      _currentStep = 'Loading academic terms...';
      notifyListeners();
      try {
        final terms = await _academicRepository.fetchTermsFromFirebase(userId);
        print('✅ Loaded ${terms.length} terms');
      } catch (e) {
        print('⚠️  Error loading terms: $e');
      }
      completedSteps++;
      _progress = completedSteps / totalSteps;
      notifyListeners();

      // 4. Load subjects (for each term)
      _currentStep = 'Loading subjects...';
      notifyListeners();
      try {
        final terms = await _academicRepository.getTermsForUser(userId);
        var totalSubjects = 0;
        for (final term in terms) {
          final subjects = await _academicRepository.fetchSubjectsFromFirebase(userId, term.id);
          totalSubjects += subjects.length;
        }
        print('✅ Loaded $totalSubjects subjects across ${terms.length} terms');
      } catch (e) {
        print('⚠️  Error loading subjects: $e');
      }
      completedSteps++;
      _progress = completedSteps / totalSteps;
      notifyListeners();

      // 5. Load assignments (for each subject in each term)
      _currentStep = 'Loading assignments...';
      notifyListeners();
      try {
        final terms = await _academicRepository.getTermsForUser(userId);
        var totalAssignments = 0;
        for (final term in terms) {
          final subjects = await _academicRepository.getSubjectsForTerm(term.id);
          for (final subject in subjects) {
            final assignments = await _academicRepository.fetchAssignmentsFromFirebase(userId, term.id, subject.id);
            totalAssignments += assignments.length;
          }
        }
        print('✅ Loaded $totalAssignments assignments');
      } catch (e) {
        print('⚠️  Error loading assignments: $e');
      }
      completedSteps++;
      _progress = completedSteps / totalSteps;
      notifyListeners();

      // 6. Load class templates (for each subject in each term)
      _currentStep = 'Loading class templates...';
      notifyListeners();
      try {
        final terms = await _academicRepository.getTermsForUser(userId);
        var totalClassTemplates = 0;
        for (final term in terms) {
          final subjects = await _academicRepository.getSubjectsForTerm(term.id);
          for (final subject in subjects) {
            final classTemplates = await _academicRepository.fetchClassTemplatesFromFirebase(userId, term.id, subject.id);
            totalClassTemplates += classTemplates.length;
          }
        }
        print('✅ Loaded $totalClassTemplates class templates');
      } catch (e) {
        print('⚠️  Error loading class templates: $e');
      }
      completedSteps++;
      _progress = completedSteps / totalSteps;
      notifyListeners();

      // 7. Load exams (for each subject in each term)
      _currentStep = 'Loading exams...';
      notifyListeners();
      try {
        final terms = await _academicRepository.getTermsForUser(userId);
        var totalExams = 0;
        for (final term in terms) {
          final subjects = await _academicRepository.getSubjectsForTerm(term.id);
          for (final subject in subjects) {
            final exams = await _academicRepository.fetchExamsFromFirebase(userId, term.id, subject.id);
            totalExams += exams.length;
          }
        }
        print('✅ Loaded $totalExams exams');
      } catch (e) {
        print('⚠️  Error loading exams: $e');
      }
      completedSteps++;
      _progress = completedSteps / totalSteps;
      notifyListeners();

      // 8. Load teachers
      _currentStep = 'Loading teachers...';
      notifyListeners();
      try {
        final teachers = await _teacherRepository.fetchTeachersFromFirebase(userId);
        print('✅ Loaded ${teachers.length} teachers');
      } catch (e) {
        print('⚠️  Error loading teachers: $e');
      }
      completedSteps++;
      _progress = completedSteps / totalSteps;
      notifyListeners();

      // 9. Load holidays
      _currentStep = 'Loading holidays...';
      notifyListeners();
      try {
        final holidays = await _holidayRepository.fetchHolidaysFromFirebase(userId);
        print('✅ Loaded ${holidays.length} holidays');
      } catch (e) {
        print('⚠️  Error loading holidays: $e');
      }
      completedSteps++;
      _progress = completedSteps / totalSteps;
      notifyListeners();

      // 10. Load groups
      _currentStep = 'Loading groups...';
      notifyListeners();
      try {
        final groups = await _groupRepository.fetchGroupsOwnedByUserFromFirebase(userId);
        print('✅ Loaded ${groups.length} groups');
      } catch (e) {
        print('⚠️  Error loading groups: $e');
      }
      completedSteps++;
      _progress = 1.0;
      notifyListeners();

      print('✅ ========== INITIAL DATA LOAD COMPLETE ==========');
      _currentStep = 'Complete';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Initial load error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load only essential data (faster initial load)
  Future<void> loadEssentialData(String userId) async {
    _isLoading = true;
    _progress = 0.0;
    _error = null;
    notifyListeners();

    try {
      print('🚀 ========== ESSENTIAL DATA LOAD STARTED ==========');

      // Load user profile
      _currentStep = 'Loading profile...';
      _progress = 0.25;
      notifyListeners();
      await _userRepository.fetchUserFromFirebase(userId);

      // Load settings
      _currentStep = 'Loading settings...';
      _progress = 0.5;
      notifyListeners();
      await _settingsRepository.getOrCreateSettings(userId);

      // Load terms (academic planning is core functionality)
      _currentStep = 'Loading terms...';
      _progress = 0.75;
      notifyListeners();
      await _academicRepository.fetchTermsFromFirebase(userId);

      _progress = 1.0;
      _currentStep = 'Complete';
      print('✅ ========== ESSENTIAL DATA LOAD COMPLETE ==========');

      _isLoading = false;
      notifyListeners();

      // Load remaining data in background
      loadRemainingDataInBackground(userId);
    } catch (e) {
      print('❌ Essential load error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load remaining data in the background after essential data is loaded
  Future<void> loadRemainingDataInBackground(String userId) async {
    print('🔄 Loading remaining data in background...');

    try {
      // Load subjects (for each term)
      final terms = await _academicRepository.getTermsForUser(userId);
      for (final term in terms) {
        await _academicRepository.fetchSubjectsFromFirebase(userId, term.id);
      }

      // Load assignments, class templates, and exams (for each subject in each term)
      for (final term in terms) {
        final subjects = await _academicRepository.getSubjectsForTerm(term.id);
        for (final subject in subjects) {
          await _academicRepository.fetchAssignmentsFromFirebase(userId, term.id, subject.id);
          await _academicRepository.fetchClassTemplatesFromFirebase(userId, term.id, subject.id);
          await _academicRepository.fetchExamsFromFirebase(userId, term.id, subject.id);
        }
      }

      // Load teachers
      await _teacherRepository.fetchTeachersFromFirebase(userId);

      // Load holidays
      await _holidayRepository.fetchHolidaysFromFirebase(userId);

      // Load groups
      await _groupRepository.fetchGroupsOwnedByUserFromFirebase(userId);

      print('✅ Background data load complete');
    } catch (e) {
      print('⚠️  Background load error: $e');
    }
  }

  /// Check if this is the user's first login (no local data)
  Future<bool> isFirstLogin(String userId) async {
    try {
      final user = await _userRepository.getUserByUid(userId);
      return user == null;
    } catch (e) {
      return true; // Assume first login if error
    }
  }

  /// Clear progress and reset state
  void reset() {
    _isLoading = false;
    _progress = 0.0;
    _currentStep = '';
    _error = null;
    notifyListeners();
  }
}
