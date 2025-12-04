import 'package:flutter/material.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../models/settings_model.dart';
import '../../models/helpers/grading_scale_model.dart';
import '../../services/holidays/holiday_service.dart';
import '../../core/constants/enums.dart';

enum SettingsViewState { idle, loading, saving, error, success }

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  final HolidayRepository _holidayRepository;
  final String _userId;

  Settings? _settings;
  Settings? get settings => _settings;

  SettingsViewState _state = SettingsViewState.idle;
  SettingsViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Form controllers
  final TextEditingController defaultClassDurationController = TextEditingController();
  final TextEditingController minPointsController = TextEditingController();
  final TextEditingController maxPointsController = TextEditingController();

  // Available countries from API
  List<Map<String, String>> _availableCountries = [];
  List<Map<String, String>> get availableCountries => _availableCountries;

  bool _isLoadingCountries = false;
  bool get isLoadingCountries => _isLoadingCountries;

  // Selected country code
  String _selectedCountryCode = 'CO';
  String get selectedCountryCode => _selectedCountryCode;

  // Selected weekdays
  List<int> _selectedWeekdays = [];
  List<int> get selectedWeekdays => _selectedWeekdays;

  // Selected grading scale type
  GradingScaleType _selectedGradingScaleType = GradingScaleType.percentage;
  GradingScaleType get selectedGradingScaleType => _selectedGradingScaleType;

  // Letter grades list (for letter grading scale)
  List<LetterGrade> _letterGrades = [];
  List<LetterGrade> get letterGrades => _letterGrades;

  // Points config
  PointsConfig? _pointsConfig;
  PointsConfig? get pointsConfig => _pointsConfig;

  SettingsViewModel({
    required SettingsRepository repository,
    required HolidayRepository holidayRepository,
    required String userId,
  })  : _repository = repository,
        _holidayRepository = holidayRepository,
        _userId = userId {
    loadSettings();
    fetchAvailableCountries();
  }

  @override
  void dispose() {
    defaultClassDurationController.dispose();
    minPointsController.dispose();
    maxPointsController.dispose();
    super.dispose();
  }

  /// Fetch available countries from API
  Future<void> fetchAvailableCountries() async {
    _isLoadingCountries = true;
    notifyListeners();

    try {
      final holidayService = HolidayService();
      _availableCountries = await holidayService.getAvailableCountries();
      print('✅ Loaded ${_availableCountries.length} available countries');
    } catch (e) {
      print('⚠️  Error fetching countries: $e');
      // Use fallback list if API fails
      _availableCountries = [
        {'code': 'CO', 'name': 'Colombia'},
        {'code': 'US', 'name': 'United States'},
        {'code': 'MX', 'name': 'Mexico'},
        {'code': 'ES', 'name': 'Spain'},
      ];
    } finally {
      _isLoadingCountries = false;
      notifyListeners();
    }
  }

  /// Update selected country code
  void updateCountryCode(String countryCode) {
    _selectedCountryCode = countryCode;
    notifyListeners();
  }

  /// Load settings from repository
  Future<void> loadSettings() async {
    _setState(SettingsViewState.loading);
    _errorMessage = null;

    try {
      _settings = await _repository.getOrCreateSettings(_userId);
      _populateFormFields();
      _setState(SettingsViewState.success);
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
      _setState(SettingsViewState.error);
    }
  }

  /// Populate form fields from settings
  void _populateFormFields() {
    if (_settings == null) return;

    defaultClassDurationController.text = _settings!.defaultClassDuration.toString();
    _selectedCountryCode = _settings!.holidayCountry;
    _selectedWeekdays = List.from(_settings!.weekdays);
    _selectedGradingScaleType = _settings!.gradingScale.type;

    // Populate grading scale specific fields
    if (_selectedGradingScaleType == GradingScaleType.letter) {
      _letterGrades = _settings!.gradingScale.letterGrades ?? _getDefaultLetterGrades();
    } else if (_selectedGradingScaleType == GradingScaleType.points) {
      _pointsConfig = _settings!.gradingScale.pointsConfig ?? PointsConfig(minPoints: 0, maxPoints: 100);
      minPointsController.text = _pointsConfig!.minPoints.toString();
      maxPointsController.text = _pointsConfig!.maxPoints.toString();
    }
  }

  /// Toggle weekday selection
  void toggleWeekday(int dayIndex) {
    if (_selectedWeekdays.contains(dayIndex)) {
      if (_selectedWeekdays.length > 1) {
        _selectedWeekdays.remove(dayIndex);
      }
    } else {
      _selectedWeekdays.add(dayIndex);
    }
    _selectedWeekdays.sort();
    notifyListeners();
  }

  /// Update grading scale type
  void updateGradingScaleType(GradingScaleType type) {
    _selectedGradingScaleType = type;

    // Initialize defaults for the selected type
    if (type == GradingScaleType.letter && _letterGrades.isEmpty) {
      _letterGrades = _getDefaultLetterGrades();
    } else if (type == GradingScaleType.points && _pointsConfig == null) {
      _pointsConfig = PointsConfig(minPoints: 0, maxPoints: 100);
      minPointsController.text = '0';
      maxPointsController.text = '100';
    }

    notifyListeners();
  }

  /// Update points configuration
  void updatePointsConfig() {
    final minPoints = double.tryParse(minPointsController.text) ?? 0;
    final maxPoints = double.tryParse(maxPointsController.text) ?? 100;
    _pointsConfig = PointsConfig(minPoints: minPoints, maxPoints: maxPoints);
    notifyListeners();
  }

  /// Save settings
  Future<void> saveSettings() async {
    _setState(SettingsViewState.saving);
    _errorMessage = null;

    try {
      // Validate inputs
      final defaultClassDuration = int.tryParse(defaultClassDurationController.text);
      if (defaultClassDuration == null || defaultClassDuration <= 0) {
        throw Exception('Default class duration must be a positive number');
      }

      if (_selectedCountryCode.isEmpty || _selectedCountryCode.length != 2) {
        throw Exception('Please select a valid country');
      }

      if (_selectedWeekdays.isEmpty) {
        throw Exception('At least one weekday must be selected');
      }

      // Check if country changed - need to refresh holidays
      final countryChanged = _settings?.holidayCountry != _selectedCountryCode.toUpperCase();

      // Build grading scale based on selected type
      GradingScale gradingScale;
      if (_selectedGradingScaleType == GradingScaleType.percentage) {
        gradingScale = GradingScale(type: GradingScaleType.percentage);
      } else if (_selectedGradingScaleType == GradingScaleType.letter) {
        gradingScale = GradingScale(
          type: GradingScaleType.letter,
          letterGrades: _letterGrades,
        );
      } else {
        // Points
        final minPoints = double.tryParse(minPointsController.text) ?? 0;
        final maxPoints = double.tryParse(maxPointsController.text) ?? 100;
        if (maxPoints <= minPoints) {
          throw Exception('Max points must be greater than min points');
        }
        gradingScale = GradingScale(
          type: GradingScaleType.points,
          pointsConfig: PointsConfig(minPoints: minPoints, maxPoints: maxPoints),
        );
      }

      // Create updated settings
      final updatedSettings = Settings(
        defaultClassDuration: defaultClassDuration,
        weekdays: _selectedWeekdays,
        gradingScale: gradingScale,
        holidayCountry: _selectedCountryCode.toUpperCase(),
        updatedAt: DateTime.now(),
      );

      // Save to repository
      await _repository.saveSettings(updatedSettings, _userId);
      _settings = updatedSettings;

      // If country changed, fetch new holidays
      if (countryChanged) {
        print('🌍 Country changed to ${_selectedCountryCode}, fetching new holidays...');
        try {
          await _holidayRepository.fetchAndSaveApiHolidays(
            _userId,
            _selectedCountryCode.toUpperCase(),
          );
          print('✅ Holidays updated for new country');
        } catch (e) {
          print('⚠️  Error fetching holidays for new country: $e');
          // Don't fail the settings save if holiday fetch fails
        }
      }

      _setState(SettingsViewState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(SettingsViewState.error);
    }
  }

  /// Get default letter grades (standard US grading scale)
  List<LetterGrade> _getDefaultLetterGrades() {
    return [
      LetterGrade(letter: 'A', minPercentage: 90, maxPercentage: 100, gpaValue: 4.0),
      LetterGrade(letter: 'B', minPercentage: 80, maxPercentage: 89, gpaValue: 3.0),
      LetterGrade(letter: 'C', minPercentage: 70, maxPercentage: 79, gpaValue: 2.0),
      LetterGrade(letter: 'D', minPercentage: 60, maxPercentage: 69, gpaValue: 1.0),
      LetterGrade(letter: 'F', minPercentage: 0, maxPercentage: 59, gpaValue: 0.0),
    ];
  }

  /// Get weekday name
  String getWeekdayName(int index) {
    const names = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return names[index];
  }

  /// Get short weekday name
  String getShortWeekdayName(int index) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[index];
  }

  /// Private method to update state and notify listeners
  void _setState(SettingsViewState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Check if form is valid
  bool get isFormValid {
    return defaultClassDurationController.text.isNotEmpty &&
        _selectedCountryCode.isNotEmpty &&
        _selectedWeekdays.isNotEmpty;
  }

  /// Get country name from code
  String getCountryName(String code) {
    try {
      return _availableCountries.firstWhere(
        (c) => c['code'] == code,
        orElse: () => {'name': code},
      )['name']!;
    } catch (e) {
      return code;
    }
  }
}
