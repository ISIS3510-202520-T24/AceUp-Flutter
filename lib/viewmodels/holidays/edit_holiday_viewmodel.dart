import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist

import '../../data/repositories/holiday_repository.dart';
import '../../models/holidays/holiday_model.dart';
import '../../services/auth/auth_service.dart';
import '../../core/constants/enums.dart';

class EditHolidayViewModel extends ChangeNotifier {
  final AuthService _authService;
  final HolidayRepository _repository;
  final _uuid = const Uuid(); // ignore: creation_with_non_type
  final String? holidayId;

  EditViewState _state = EditViewState.idle;
  EditViewState get state => _state;

  Holiday? _holiday;
  Holiday? get holiday => _holiday;

  bool get isEditMode => holidayId != null;
  bool get isCreateMode => holidayId == null;

  // Only user-created holidays can be edited
  bool get canEdit => _holiday?.isUserCreated ?? true;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  late TextEditingController nameController;

  DateTime _startDate = DateTime.now();
  DateTime get startDate => _startDate;

  DateTime _endDate = DateTime.now();
  DateTime get endDate => _endDate;

  EditHolidayViewModel({
    this.holidayId,
    AuthService? authService,
    required HolidayRepository repository,
  })  : _authService = authService ?? AuthService(),
        _repository = repository {
    _initializeControllers();
    if (isEditMode) {
      _loadExistingHoliday();
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController();
  }

  Future<void> _loadExistingHoliday() async {
    if (holidayId == null) return;

    _state = EditViewState.loading;
    notifyListeners();

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = EditViewState.error;
      notifyListeners();
      return;
    }

    try {
      _holiday = await _repository.getHolidayById(holidayId!);

      if (_holiday != null) {
        // Check if this is an API holiday - it should not be editable
        if (_holiday!.isFromApi) {
          _errorMessage = 'API holidays cannot be edited';
          _state = EditViewState.error;
          notifyListeners();
          return;
        }

        nameController.text = _holiday!.name;
        _startDate = _holiday!.startDate;
        _endDate = _holiday!.endDate;

        _state = EditViewState.idle;
        _errorMessage = null;
      } else {
        _errorMessage = 'Holiday not found';
        _state = EditViewState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load holiday: $e';
      _state = EditViewState.error;
      print('Error loading holiday: $e');
    }

    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    // Ensure end date is not before start date
    if (_endDate.isBefore(_startDate)) {
      _endDate = _startDate;
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  bool _validateFields() {
    if (nameController.text.trim().isEmpty) {
      _errorMessage = 'Please enter a holiday name';
      return false;
    }

    if (_endDate.isBefore(_startDate)) {
      _errorMessage = 'End date cannot be before start date';
      return false;
    }

    _errorMessage = null;
    return true;
  }

  Future<bool> saveHoliday() async {
    if (!_validateFields()) {
      notifyListeners();
      return false;
    }

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    // Prevent editing API holidays
    if (isEditMode && _holiday?.isFromApi == true) {
      _errorMessage = 'Cannot edit API holidays';
      notifyListeners();
      return false;
    }

    _state = EditViewState.saving;
    notifyListeners();

    try {
      final now = DateTime.now();

      final holiday = Holiday(
        id: holidayId ?? _uuid.v4(),
        name: nameController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        source: 'user', // Always set to 'user' for custom holidays
        createdAt: _holiday?.createdAt ?? now,
        updatedAt: now,
      );

      await _repository.saveHoliday(holiday, userId);

      _state = EditViewState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save holiday: $e';
      _state = EditViewState.error;
      notifyListeners();
      print('Error saving holiday: $e');
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}