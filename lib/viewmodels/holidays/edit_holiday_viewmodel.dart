import 'package:flutter/src/widgets/basic.dart';
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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime _startDate = DateTime.now();
  DateTime get startDate => _startDate;

  DateTime _endDate = DateTime.now();
  DateTime get endDate => _endDate;

  EditHolidayViewModel({
    this.holidayId,
    AuthService? authService,
    required HolidayRepository repository,
  })  : _authService = authService ?? AuthService(),
        _repository = repository{
          
        }
}