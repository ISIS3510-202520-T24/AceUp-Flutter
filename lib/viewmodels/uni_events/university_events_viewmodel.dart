import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/uni_events/university_event_model.dart';
import '../../services/uni_events/university_events_service.dart';
import '../../services/auth/auth_service.dart';
import '../../data/repositories/event_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../core/constants/enums.dart';

class UniversityEventsViewModel extends ChangeNotifier {
  final UniversityEventsService _eventsService;
  final EventRepository _eventRepository;
  final ConnectivityManager _connectivity;
  final AuthService _authService;

  StreamSubscription<bool>? _connectivitySubscription;

  UniversityEventsViewModel({
    required UniversityEventsService eventsService,
    required EventRepository eventRepository,
    required ConnectivityManager connectivity,
    required AuthService authService,
  })  : _eventsService = eventsService,
        _eventRepository = eventRepository,
        _connectivity = connectivity,
        _authService = authService {
    _init();
  }

  // State
  OfflineViewState _state = OfflineViewState.idle;
  OfflineViewState get state => _state;

  List<UniversityEvent> _events = [];
  List<UniversityEvent> get events => _events;

  List<UniversityEvent> _filteredEvents = [];
  List<UniversityEvent> get filteredEvents => _filteredEvents;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  // Available categories for filtering
  List<String> get categories {
    final cats = {'All', ...events.map((e) => e.category ?? 'Other')};
    return cats.toList()..sort();
  }

  void _init() {
    _loadEvents();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline && _state == OfflineViewState.offline) {
        fetchEvents();
      }
    });
  }

  String? get _userId => _authService.currentUser?.uid;

  /// Load events (from cache if offline, fetch if online)
  Future<void> _loadEvents() async {
    if (_userId == null) {
      _state = OfflineViewState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    if (!_connectivity.isOnline) {
      await _loadOfflineEvents();
      return;
    }

    await fetchEvents();
  }

  /// Load events from cache (offline mode)
  Future<void> _loadOfflineEvents() async {
    _state = OfflineViewState.loading;
    notifyListeners();

    try {
      _events = await _eventRepository.getOfflineEvents(_userId!);
      _filteredEvents = _events;
      
      if (_events.isEmpty) {
        _state = OfflineViewState.offline;
        _errorMessage = 'No cached events available offline';
      } else {
        _state = OfflineViewState.success;
        _errorMessage = null;
      }
    } catch (e) {
      _state = OfflineViewState.error;
      _errorMessage = 'Failed to load cached events: ${e.toString()}';
      print('Error loading offline events: $e');
    }

    notifyListeners();
  }

  /// Fetch events from the university website
  Future<void> fetchEvents() async {
    if (_userId == null) {
      _state = OfflineViewState.error;
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    if (!_connectivity.isOnline) {
      await _loadOfflineEvents();
      return;
    }

    _state = OfflineViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch events from service
      final fetchedEvents = await _eventsService.fetchEvents();
      
      // Cache for offline use
      await _eventRepository.cacheEvents(fetchedEvents);
      
      // Merge with user events (added to calendar)
      _events = await _eventRepository.mergeEventsWithUserData(
        fetchedEvents,
        _userId!,
      );
      
      _filteredEvents = _events;
      _state = OfflineViewState.success;
      _errorMessage = null;
      
      // Clean up old cache
      await _eventRepository.cleanupExpiredCache();
    } catch (e) {
      // Try to load from cache on error
      try {
        _events = await _eventRepository.getOfflineEvents(_userId!);
        _filteredEvents = _events;
        _state = _events.isEmpty ? OfflineViewState.error : OfflineViewState.success;
        _errorMessage = _events.isEmpty ? 'Failed to load events: ${e.toString()}' : null;
      } catch (cacheError) {
        _state = OfflineViewState.error;
        _errorMessage = 'Failed to load events: ${e.toString()}';
      }
      print('Error fetching events: $e');
    }

    notifyListeners();
  }

  /// Add event to user's calendar
  Future<void> addEventToCalendar(
    String eventId, {
    String? userNotes,
    String? userLocation,
    DateTime? userStartDate,
    DateTime? userEndDate,
  }) async {
    if (_userId == null) return;

    try {
      final event = _events.firstWhere((e) => e.id == eventId);
      
      await _eventRepository.addEventToCalendar(
        event,
        _userId!,
        userNotes: userNotes,
        userLocation: userLocation,
      );

      // Update local state
      _updateEventInLists(eventId, (event) => event.copyWith(
        isAddedToCalendar: true,
        userNotes: userNotes,
        userLocation: userLocation,
        addedAt: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      print('Error adding event to calendar: $e');
      _errorMessage = 'Failed to add event: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Remove event from user's calendar
  Future<void> removeEventFromCalendar(String eventId) async {
    if (_userId == null) return;

    try {
      await _eventRepository.removeEventFromCalendar(eventId, _userId!);

      // Update local state
      _updateEventInLists(eventId, (event) => event.copyWith(
        isAddedToCalendar: false,
        userNotes: null,
        userLocation: null,
        addedAt: null,
      ));

      notifyListeners();
    } catch (e) {
      print('Error removing event from calendar: $e');
      _errorMessage = 'Failed to remove event: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update user event customizations
  Future<void> updateUserEvent(
    String eventId, {
    String? userNotes,
    String? userLocation,
    DateTime? userStartDate,
    DateTime? userEndDate,
  }) async {
    if (_userId == null) return;

    try {
      await _eventRepository.updateUserEvent(
        eventId,
        _userId!,
        userNotes: userNotes,
        userLocation: userLocation,
      );

      // Update local state
      _updateEventInLists(eventId, (event) => event.copyWith(
        userNotes: userNotes,
        userLocation: userLocation,
      ));

      notifyListeners();
    } catch (e) {
      print('Error updating event: $e');
      _errorMessage = 'Failed to update event: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Helper to update event in both lists
  void _updateEventInLists(String eventId, UniversityEvent Function(UniversityEvent) update) {
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      _events[eventIndex] = update(_events[eventIndex]);
    }

    final filteredIndex = _filteredEvents.indexWhere((e) => e.id == eventId);
    if (filteredIndex != -1) {
      _filteredEvents[filteredIndex] = update(_filteredEvents[filteredIndex]);
    }
  }

  /// Filter events by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    
    if (category == 'All') {
      _filteredEvents = _events;
    } else {
      _filteredEvents = _events
          .where((event) => event.category == category)
          .toList();
    }
    
    notifyListeners();
  }

  /// Sort events by date
  void sortByDate({bool ascending = true}) {
    _filteredEvents.sort((a, b) {
      final dateA = a.startDateTime;
      final dateB = b.startDateTime;
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    notifyListeners();
  }

  /// Get events happening soon (within next 7 days)
  List<UniversityEvent> get upcomingEvents {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    return _events.where((event) {
      final eventDate = event.startDateTime;
      return eventDate.isAfter(now) && eventDate.isBefore(weekFromNow);
    }).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  /// Get events added to calendar
  List<UniversityEvent> get calendarEvents {
    return _events.where((e) => e.isAddedToCalendar).toList();
  }

  /// Get event by ID
  UniversityEvent? getEventById(String eventId) {
    try {
      return _events.firstWhere((e) => e.id == eventId);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}