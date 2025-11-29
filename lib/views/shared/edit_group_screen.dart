import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ignore: uri_does_not_exist

import '../../core/connectivity/connectivity_manager.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/storage/group_image_service.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/shared/edit_group_viewmodel.dart';
import '../../widgets/top_bar.dart';

class EditGroupScreen extends StatelessWidget {
  final String? groupId;

  const EditGroupScreen({super.key, this.groupId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditGroupViewModel(
        groupId: groupId,
        groupRepository: context.read<GroupRepository>(),
        userRepository: context.read<UserRepository>(),
        imageService: GroupImageService(),
        connectivity: context.read<ConnectivityManager>(),
      ),
      child: const _EditGroupScreenContent(),
    );
  }
}

class _EditGroupScreenContent extends StatelessWidget {
  const _EditGroupScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditGroupViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: TopBar(
        title: viewModel.isCreateMode ? 'Create Group' : 'Edit Group',
        leftControlType: LeftControlType.cancel,
        rightControlType: RightControlType.save,
        onRightPressed: () => _saveGroup(context, viewModel),
      ),
      body: viewModel.state == EditGroupViewState.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offline indicator
                  if (!viewModel.isOnline)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colors.primary.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_off, size: 16, color: colors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You\'re offline. Changes will sync when you\'re back online.',
                              style: AppTypography.bodyS.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Image section
                  _buildImageSection(context, viewModel, colors),

                  const SizedBox(height: 24),

                  // Group name field
                  TextField(
                    controller: viewModel.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'Enter group name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description field
                  TextField(
                    controller: viewModel.descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Enter group description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // Color selection
                  Text(
                    'Group Color',
                    style: AppTypography.h5.copyWith(color: colors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  _buildColorPicker(context, viewModel, colors),

                  const SizedBox(height: 24),

                  // Members section
                  Text(
                    'Members',
                    style: AppTypography.h5.copyWith(color: colors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add members by their user ID and nickname',
                    style: AppTypography.bodyS.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Member list
                  ...List.generate(
                    viewModel.memberInputs.length,
                    (index) => _buildMemberField(
                      context,
                      viewModel,
                      index,
                      colors,
                    ),
                  ),

                  // Add member button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: viewModel.addMemberField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add member'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Error message
                  if (viewModel.state == EditGroupViewState.error &&
                      viewModel.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(AppIcons.error, color: colors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: AppTypography.bodyS.copyWith(
                                color: colors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    EditGroupViewModel viewModel,
    ColorScheme colors,
  ) {
    return Center(
      child: Column(
        children: [
          // Image preview
          _buildImagePreview(viewModel, colors),

          const SizedBox(height: 16),

          // Image selection buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _showPresetImagePicker(context, viewModel),
                icon: const Icon(Icons.grid_view, size: 18),
                label: const Text('Presets'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: viewModel.pickGalleryImage,
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Upload'),
              ),
              if (viewModel.getCurrentImagePath() != null)
                TextButton.icon(
                  onPressed: viewModel.clearImageSelection,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(EditGroupViewModel viewModel, ColorScheme colors) {
    if (viewModel.selectedGalleryPath != null) {
      // Show gallery image
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(viewModel.selectedGalleryPath!)),
      );
    } else if (viewModel.selectedPresetImage != null) {
      // Show preset
      return CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(viewModel.selectedPresetImage!),
      );
    } else if (viewModel.existingImageUrl != null) {
      // Show existing image
      return CachedNetworkImage( //ignore: undefined_method
        imageUrl: viewModel.existingImageUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 50,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircleAvatar(
          radius: 50,
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const CircleAvatar(
          radius: 50,
          child: Icon(Icons.group, size: 50),
        ),
      );
    } else {
      // Default image
      return CircleAvatar(
        radius: 50,
        backgroundColor: colors.primaryContainer,
        child: Icon(Icons.group, size: 50, color: colors.onPrimaryContainer),
      );
    }
  }

  Widget _buildColorPicker(
    BuildContext context,
    EditGroupViewModel viewModel,
    ColorScheme colors,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: viewModel.colorOptions.map((colorHex) {
        final color = Color(int.parse('0xFF${colorHex.substring(1)}'));
        final isSelected = viewModel.selectedColor == colorHex;

        return GestureDetector(
          onTap: () => viewModel.setColor(colorHex),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: colors.onSurface, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(Icons.check, color: colors.onPrimary, size: 24)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMemberField(
    BuildContext context,
    EditGroupViewModel viewModel,
    int index,
    ColorScheme colors,
  ) {
    final input = viewModel.memberInputs[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: input.userIdController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    hintText: 'user123',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: input.nicknameController,
                  decoration: const InputDecoration(
                    labelText: 'Nickname',
                    hintText: 'John Doe',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (viewModel.memberInputs.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: IconButton(
                onPressed: () => viewModel.removeMemberField(index),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  void _showPresetImagePicker(
    BuildContext context,
    EditGroupViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: EditGroupViewModel.presetImages.length,
            itemBuilder: (c, i) {
              final asset = EditGroupViewModel.presetImages[i];
              return GestureDetector(
                onTap: () {
                  viewModel.setPresetImage(asset);
                  Navigator.pop(ctx);
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage(asset),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _saveGroup(
      BuildContext context, EditGroupViewModel viewModel) async {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final success = await viewModel.saveGroup();

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to save group'),
        ),
      );
    }
  }
}
