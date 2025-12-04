// lib/viewmodels/calendar_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/planner/class_template_model.dart';
import '../../models/assignments/assignment_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../services/cache/calendar_cache_service.dart';

enum CalendarTab { timetable, assignments }

/// CalendarViewModel with advanced features:
/// - Stream-based real-time updates for active term
/// - LRU cache for classes and assignments
/// - SharedPreferences for persisting last selected date
/// - Connectivity-aware data loading
class CalendarViewModel extends ChangeNotifier {
  final AcademicRepository _repository;
  final AuthService _authService = AuthService();
  final CalendarCacheService _cache = CalendarCacheService();

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  CalendarTab _selectedTab = CalendarTab.timetable;
  
  bool _loading = false;
  List<ClassTemplate> _classesForDay = [];
  List<Assignment> _assignmentsForDay = [];
  
  // Stream subscription for real-time term updates
  StreamSubscription? _termSubscription;
  String? _activeTermId;

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;
  CalendarTab get selectedTab => _selectedTab;
  bool get loading => _loading;
  List<ClassTemplate> get classesForDay => _classesForDay;
  List<Assignment> get assignmentsForDay => _assignmentsForDay;

  CalendarViewModel(this._repository) {
    _initializeViewModel();
  }

  /// Initialize ViewModel with:
  /// 1. Load last selected date from SharedPreferences
  /// 2. Subscribe to active term changes via Stream
  /// 3. Load initial data
  Future<void> _initializeViewModel() async {
    await _loadLastSelectedDate();
    _subscribeToActiveTerm();
    await _loadDataForSelectedDate();
  }

  /// Load last selected date from SharedPreferences
  /// Strategy: Persist user's last viewed date for better UX
  Future<void> _loadLastSelectedDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDateStr = prefs.getString('calendar_last_selected_date');
      if (savedDateStr != null) {
        final savedDate = DateTime.parse(savedDateStr);
        // Only use saved date if it's within 30 days
        if (DateTime.now().difference(savedDate).inDays.abs() <= 30) {
          _selectedDate = savedDate;
          _focusedMonth = DateTime(savedDate.year, savedDate.month, 1);
          print('📅 Restored last selected date: $savedDate');
        }
      }
    } catch (e) {
      print('⚠️ Error loading last selected date: $e');
    }
  }

  /// Save selected date to SharedPreferences
  Future<void> _saveSelectedDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('calendar_last_selected_date', _selectedDate.toIso8601String());
      print('💾 Saved selected date: $_selectedDate');
    } catch (e) {
      print('⚠️ Error saving selected date: $e');
    }
  }

  /// Subscribe to active term changes using Stream
  /// Strategy: Real-time updates when term is activated/deactivated
  void _subscribeToActiveTerm() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    print('📡 Subscribing to active term stream...');
    _termSubscription = _repository.watchActiveTermForUser(userId).listen(
      (activeTerm) {
        if (activeTerm?.id != _activeTermId) {
          _activeTermId = activeTerm?.id;
          print('🔄 Active term changed: ${activeTerm?.name ?? 'None'}');
          // Clear cache when term changes
          _cache.clearCache();
          // Reload data
          _loadDataForSelectedDate();
        }
      },
      onError: (error) {
        print('❌ Error in term stream: $error');
      },
    );
  }

  @override
  void dispose() {
    _termSubscription?.cancel();
    super.dispose();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _saveSelectedDate(); // Persist selection
    _loadDataForSelectedDate();
    notifyListeners();
  }

  void changeMonth(int monthOffset) {
    _focusedMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + monthOffset,
      1,
    );
    notifyListeners();
  }

  void selectTab(int index) {
    if (index >= 0 && index < CalendarTab.values.length) {
      _selectedTab = CalendarTab.values[index];
      notifyListeners();
    }
  }

  /// Load data with LRU cache strategy
  /// 1. Check cache first (fast)
  /// 2. If cache miss, load from database
  /// 3. Cache the result for future use
  Future<void> _loadDataForSelectedDate() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    _loading = true;
    notifyListeners();

    try {
      // Try to load from cache first
      final cachedClasses = _cache.getCachedClasses(_selectedDate);
      final cachedAssignments = _cache.getCachedAssignments(_selectedDate);

      if (cachedClasses != null && cachedAssignments != null) {
        // Cache hit - use cached data
        _classesForDay = cachedClasses;
        _assignmentsForDay = cachedAssignments;
        print('⚡ Loaded from cache for $_selectedDate');
      } else {
        // Cache miss - load from database
        print('🔍 Loading from database for $_selectedDate');
        
        // Load classes for the selected day
        _classesForDay = await _getClassesForDate(_selectedDate, userId);
        _cache.cacheClasses(_selectedDate, _classesForDay);
        
        // Load assignments for the selected day
        _assignmentsForDay = await _getAssignmentsForDate(_selectedDate, userId);
        _cache.cacheAssignments(_selectedDate, _assignmentsForDay);
      }
    } catch (e) {
      print('Error loading calendar data: $e');
      _classesForDay = [];
      _assignmentsForDay = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<ClassTemplate>> _getClassesForDate(DateTime date, String userId) async {
    try {
      final activeTerm = await _repository.getActiveTermForUser(userId);
      if (activeTerm == null) {
        print('No active term found for user');
        return [];
      }

      print('Active term: ${activeTerm.name} (${activeTerm.id})');
      final subjects = await _repository.getSubjectsForTerm(activeTerm.id);
      print('Found ${subjects.length} subjects for term ${activeTerm.id}');
      final List<ClassTemplate> allClasses = [];

      for (final subject in subjects) {
        final classes = await _repository.getClassTemplatesForSubject(subject.id);
        print('Subject ${subject.name}: ${classes.length} class templates');
        
        // Filter classes that occur on the selected date
        final classesForDate = classes.where((classTemplate) {
          final occurs = _doesClassOccurOnDate(classTemplate, date);
          if (occurs) {
            print('Class "${classTemplate.name}" occurs on $date');
          }
          return occurs;
        }).toList();

        print('Filtered to ${classesForDate.length} classes for date $date');
        allClasses.addAll(classesForDate);
      }

      print('Total classes for $date: ${allClasses.length}');

      // Sort by start time
      allClasses.sort((a, b) => a.startTime.compareTo(b.startTime));
      return allClasses;
    } catch (e) {
      print('Error getting classes for date: $e');
      return [];
    }
  }

  Future<List<Assignment>> _getAssignmentsForDate(DateTime date, String userId) async {
    try {
      final activeTerm = await _repository.getActiveTermForUser(userId);
      if (activeTerm == null) {
        print('No active term found for user');
        return [];
      }

      final subjects = await _repository.getSubjectsForTerm(activeTerm.id);
      print('Found ${subjects.length} subjects for term ${activeTerm.id}');
      final List<Assignment> allAssignments = [];

      for (final subject in subjects) {
        final assignments = await _repository.getAssignmentsForSubject(subject.id);
        print('Subject ${subject.name}: ${assignments.length} assignments');
        
        // Filter assignments due on the selected date
        final assignmentsForDate = assignments.where((assignment) {
          final isSame = _isSameDay(assignment.dueDate, date);
          print('Assignment "${assignment.title}" due ${assignment.dueDate} vs selected $date: $isSame');
          return isSame;
        }).toList();

        print('Filtered to ${assignmentsForDate.length} assignments for date $date');
        allAssignments.addAll(assignmentsForDate);
      }

      print('Total assignments for $date: ${allAssignments.length}');

      // Sort by time (if available) then by priority
      allAssignments.sort((a, b) {
        if (a.dueTime != null && b.dueTime != null) {
          return a.dueTime!.compareTo(b.dueTime!);
        }
        return b.priority.index.compareTo(a.priority.index);
      });
      
      return allAssignments;
    } catch (e) {
      print('Error getting assignments for date: $e');
      return [];
    }
  }

  bool _doesClassOccurOnDate(ClassTemplate classTemplate, DateTime date) {
    // Normalize dates to compare only year/month/day (ignore time)
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startDateOnly = DateTime(classTemplate.startDate.year, classTemplate.startDate.month, classTemplate.startDate.day);
    final endDateOnly = DateTime(classTemplate.endDate.year, classTemplate.endDate.month, classTemplate.endDate.day);
    
    print('Checking if class "${classTemplate.name}" occurs on $dateOnly');
    print('  Start: $startDateOnly, End: $endDateOnly');
    print('  Recurrence: ${classTemplate.recurrence.selectedDays}');
    
    // Check if date is within the class template range
    if (dateOnly.isBefore(startDateOnly) || dateOnly.isAfter(endDateOnly)) {
      print('  ❌ Date is outside range');
      return false;
    }

    // Check if the day matches the recurrence pattern
    // selectedDays uses 0=Sunday, 6=Saturday, but DateTime.weekday uses 1=Monday, 7=Sunday
    // Convert DateTime.weekday to selectedDays format
    final weekday = date.weekday == 7 ? 0 : date.weekday; // Convert Sunday from 7 to 0
    print('  Date weekday: ${date.weekday} → converted to: $weekday');
    
    final matches = classTemplate.recurrence.selectedDays.contains(weekday);
    print('  ${matches ? "✓" : "❌"} Weekday ${matches ? "matches" : "does not match"}');
    
    return matches;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> refresh() async {
    print('🔄 Refreshing calendar data...');
    // Clear cache to force fresh data from database
    _cache.clearCache();
    await _loadDataForSelectedDate();
  }

  /// Clear cache for specific date (e.g., after updating an assignment)
  void invalidateDate(DateTime date) {
    _cache.clearDateCache(date);
  }
}
