import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart'; // ignore: uri_does_not_exist
import 'package:image_picker/image_picker.dart'; // ignore: uri_does_not_exist
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../models/shared/group_model.dart';
import '../../models/shared/group_member_model.dart';
import '../../models/user_model.dart' as user_model;
import '../../services/auth/auth_service.dart';
import '../../services/storage/group_image_service.dart';
import '../../core/connectivity/connectivity_manager.dart';

// ignore_for_file: undefined_identifier,

enum EditGroupViewState { idle, loading, saving, error, uploadingImage }

class MemberInput {
  final TextEditingController userIdController;
  final TextEditingController nicknameController;

  MemberInput({
    String? userId,
    String? nickname,
  })  : userIdController = TextEditingController(text: userId ?? ''),
        nicknameController = TextEditingController(text: nickname ?? '');

  void dispose() {
    userIdController.dispose();
    nicknameController.dispose();
  }
}

class EditGroupViewModel extends ChangeNotifier {
  final AuthService _authService;
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final GroupImageService _imageService;
  final ConnectivityManager? _connectivity;
  final String? groupId;

  EditGroupViewState _state = EditGroupViewState.idle;
  EditGroupViewState get state => _state;

  Group? _group;
  Group? get group => _group;

  bool get isCreateMode => groupId == null;
  bool get isEditMode => groupId != null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isOnline => _connectivity?.isOnline ?? true;

  // Form controllers
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  final List<MemberInput> memberInputs = [];

  // Color selection
  String _selectedColor = '#4CAF50';
  String get selectedColor => _selectedColor;

  // Image selection
  String? _selectedPresetImage;
  String? get selectedPresetImage => _selectedPresetImage;

  String? _selectedGalleryPath;
  String? get selectedGalleryPath => _selectedGalleryPath;

  String? _existingImageUrl;
  String? get existingImageUrl => _existingImageUrl;

  // Available users for autocomplete/search
  List<user_model.User> _availableUsers = [];
  List<user_model.User> get availableUsers => _availableUsers;

  // Predefined color palette (same as subjects)
  final List<String> colorOptions = [
    '#E57373', // Red
    '#F06292', // Pink
    '#BA68C8', // Purple
    '#9575CD', // Deep Purple
    '#7986CB', // Indigo
    '#64B5F6', // Blue
    '#4FC3F7', // Light Blue
    '#4DD0E1', // Cyan
    '#4DB6AC', // Teal
    '#81C784', // Green
    '#AED581', // Light Green
    '#FFD54F', // Amber
    '#FFB74D', // Orange
    '#FF8A65', // Deep Orange
    '#A1887F', // Brown
    '#90A4AE', // Blue Grey
  ];

  // Preset group images
  static const List<String> presetImages = [
    'assets/group_images/group_1.png',
    'assets/group_images/group_2.png',
    'assets/group_images/group_3.png',
    'assets/group_images/group_4.png',
  ];

  EditGroupViewModel({
    this.groupId,
    AuthService? authService,
    required GroupRepository groupRepository,
    required UserRepository userRepository,
    required GroupImageService imageService,
    ConnectivityManager? connectivity,
  })  : _authService = authService ?? AuthService(),
        _groupRepository = groupRepository,
        _userRepository = userRepository,
        _imageService = imageService,
        _connectivity = connectivity {
    _initializeControllers();
    _loadAvailableUsers();
    if (isEditMode) {
      _loadExistingGroup();
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    descriptionController = TextEditingController();

    // Start with one empty member field in create mode
    if (isCreateMode) {
      memberInputs.add(MemberInput());
    }
  }

  Future<void> _loadAvailableUsers() async {
    try {
      _availableUsers = await _userRepository.getAllUsers();
      notifyListeners();
    } catch (e) {
      print('Error loading available users: $e');
    }
  }

  Future<void> _loadExistingGroup() async {
    if (groupId == null) return;

    _state = EditGroupViewState.loading;
    notifyListeners();

    try {
      _group = await _groupRepository.getGroupById(groupId!);

      if (_group != null) {
        nameController.text = _group!.name;
        descriptionController.text = _group!.description ?? '';
        _selectedColor = _group!.color;
        _existingImageUrl = _group!.imageUrl;

        // Populate member inputs from existing members
        for (final member in _group!.members) {
          memberInputs.add(MemberInput(
            userId: member.userId,
            nickname: member.nickname,
          ));
        }

        _state = EditGroupViewState.idle;
        _errorMessage = null;
      } else {
        _errorMessage = 'Group not found';
        _state = EditGroupViewState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load group: $e';
      _state = EditGroupViewState.error;
      print('Error loading group: $e');
    }

    notifyListeners();
  }

  void addMemberField() {
    memberInputs.add(MemberInput());
    notifyListeners();
  }

  void removeMemberField(int index) {
    if (memberInputs.length > 1) {
      final input = memberInputs.removeAt(index);
      input.dispose();
      notifyListeners();
    }
  }

  void setColor(String color) {
    _selectedColor = color;
    notifyListeners();
  }

  void setPresetImage(String assetPath) {
    _selectedPresetImage = assetPath;
    _selectedGalleryPath = null;
    notifyListeners();
  }

  Future<void> pickGalleryImage() async {
    try {
      final picker = ImagePicker(); // ignore: undefined_method
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
      );

      if (picked != null) {
        _selectedGalleryPath = picked.path;
        _selectedPresetImage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      _state = EditGroupViewState.error;
      notifyListeners();
    }
  }

  void clearImageSelection() {
    _selectedPresetImage = null;
    _selectedGalleryPath = null;
    notifyListeners();
  }

  String? getCurrentImagePath() {
    if (_selectedGalleryPath != null) return _selectedGalleryPath;
    if (_selectedPresetImage != null) return _selectedPresetImage;
    if (_existingImageUrl != null) return _existingImageUrl;
    return null;
  }

  bool get canSave {
    final name = nameController.text.trim();
    final members = memberInputs
        .where((input) =>
            input.userIdController.text.trim().isNotEmpty &&
            input.nicknameController.text.trim().isNotEmpty)
        .toList();

    return name.isNotEmpty && members.isNotEmpty;
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<bool> saveGroup() async {
    if (!_validateForm()) {
      return false;
    }

    _state = EditGroupViewState.saving;
    _errorMessage = null;
    notifyListeners();

    final currentUserId = _authService.currentUser?.uid;

    if (currentUserId == null) {
      _errorMessage = 'User not logged in';
      _state = EditGroupViewState.error;
      notifyListeners();
      return false;
    }

    try {
      // Collect members from inputs
      final members = memberInputs
          .where((input) =>
              input.userIdController.text.trim().isNotEmpty &&
              input.nicknameController.text.trim().isNotEmpty)
          .map((input) => GroupMember(
                userId: input.userIdController.text.trim(),
                nickname: input.nicknameController.text.trim(),
                joinedAt: DateTime.now(),
              ))
          .toList();

      // Ensure current user is included as owner
      final currentUserNickname = _authService.currentUser?.displayName ?? 'Me';
      if (!members.any((m) => m.userId == currentUserId)) {
        members.insert(
          0,
          GroupMember(
            userId: currentUserId,
            nickname: currentUserNickname,
            joinedAt: DateTime.now(),
          ),
        );
      }

      // Upload image if needed
      String? imageUrl = await _handleImageUpload();

      if (isCreateMode) {
        await _createGroup(members, imageUrl);
      } else {
        await _updateGroup(members, imageUrl);
      }

      _state = EditGroupViewState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save group: $e';
      _state = EditGroupViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<String?> _handleImageUpload() async {
    File? fileToUpload;

    // Priority: gallery > preset > existing
    if (_selectedGalleryPath != null) {
      fileToUpload = File(_selectedGalleryPath!);
    } else if (_selectedPresetImage != null) {
      // Convert asset to temporary file
      try {
        final byteData = await rootBundle.load(_selectedPresetImage!);
        final buffer = byteData.buffer;
        final tempDir = await getTemporaryDirectory(); // ignore: undefined_method
        final tempFile = File(
            '${tempDir.path}/preset_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        fileToUpload = tempFile;
      } catch (e) {
        print('Error converting preset to file: $e');
      }
    } else if (_existingImageUrl != null) {
      // Keep existing image
      return _existingImageUrl;
    }

    // Upload file if available
    if (fileToUpload != null) {
      _state = EditGroupViewState.uploadingImage;
      notifyListeners();

      try {
        final groupIdForUpload = isEditMode
            ? groupId!
            : DateTime.now().millisecondsSinceEpoch.toString();

        final uploadedUrl =
            await _imageService.uploadGroupImage(fileToUpload, groupIdForUpload);

        return uploadedUrl;
      } catch (e) {
        print('Error uploading image: $e');
        _errorMessage = 'Image upload failed: $e';
        // Continue without image
        return null;
      }
    }

    return null;
  }

  Future<void> _createGroup(List<GroupMember> members, String? imageUrl) async {
    final currentUserId = _authService.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final now = DateTime.now();
    final newGroup = Group(
      id: now.millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      color: _selectedColor,
      imageUrl: imageUrl,
      ownerId: currentUserId,
      members: members,
      inviteCode: _generateInviteCode(),
      createdAt: now,
      updatedAt: now,
    );

    await _groupRepository.saveGroup(newGroup);
  }

  Future<void> _updateGroup(List<GroupMember> members, String? imageUrl) async {
    if (_group == null) {
      throw Exception('Cannot update: group not loaded');
    }

    final updatedGroup = _group!.copyWith(
      name: nameController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      color: _selectedColor,
      imageUrl: imageUrl,
      members: members,
      updatedAt: DateTime.now(),
    );

    await _groupRepository.saveGroup(updatedGroup);
  }

  bool _validateForm() {
    // Validate name
    if (nameController.text.trim().isEmpty) {
      _errorMessage = 'Group name is required';
      _state = EditGroupViewState.error;
      notifyListeners();
      return false;
    }

    // Collect valid members
    final validMembers = memberInputs.where((input) =>
        input.userIdController.text.trim().isNotEmpty &&
        input.nicknameController.text.trim().isNotEmpty);

    if (validMembers.isEmpty) {
      _errorMessage = 'At least one member is required';
      _state = EditGroupViewState.error;
      notifyListeners();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    for (final input in memberInputs) {
      input.dispose();
    }
    super.dispose();
  }
}
