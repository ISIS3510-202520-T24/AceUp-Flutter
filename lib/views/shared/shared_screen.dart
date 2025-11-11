import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para rootBundle
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // Para getTemporaryDirectory
import '../../models/group_model.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/shared/shared_viewmodel.dart';
import '../../widgets/burger_menu.dart';
import 'group_detail_screen.dart';
import '../../widgets/top_bar.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/floating_action_button.dart';
import '../../data/repositories/shared_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../widgets/connectivity_indicator.dart';
import '../../services/storage/group_image_service.dart';
import '../../services/shared/sync_service.dart';

class SharedScreenWrapper extends StatelessWidget {
  const SharedScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener las dependencias del Provider
    final repository = context.read<SharedRepository>();
    final connectivity = context.read<ConnectivityManager>();
    final syncService = context.read<SyncService>();
    
    return ChangeNotifierProvider(
      create: (_) => SharedViewModel(
        repository: repository,
        connectivity: connectivity,
        syncService: syncService,
      ),
      child: const SharedScreen(),
    );
  }
}

class SharedScreen extends StatefulWidget {
  const SharedScreen({super.key});

  @override
  State<SharedScreen> createState() => _SharedScreenState();
}

class _SharedScreenState extends State<SharedScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      context.read<SharedViewModel>().fetchGroups(userId);
    } else {
      print("Error: No user is currently logged in to fetch groups.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SharedViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final syncService = context.watch<SyncService>();

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(title: "Shared"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offline banner
          const OfflineBanner(),
          
          // Connectivity indicator
          const ConnectivityIndicator(),
          
          // Sync status banner
          if (syncService.pendingOperationsCount > 0 || syncService.isSyncing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: syncService.isSyncing 
                ? colors.primaryContainer.withValues(alpha: 0.3)
                : colors.errorContainer.withValues(alpha: 0.3),
              child: Row(
                children: [
                  if (syncService.isSyncing)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    )
                  else
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 16,
                      color: colors.error,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      syncService.isSyncing
                        ? 'Syncing ${syncService.pendingOperationsCount} items to cloud...'
                        : '${syncService.pendingOperationsCount} items waiting to sync',
                      style: AppTypography.bodyS.copyWith(
                        color: syncService.isSyncing ? colors.primary : colors.error,
                      ),
                    ),
                  ),
                  if (!syncService.isSyncing)
                    TextButton.icon(
                      onPressed: () async {
                        print('🔵 Manual sync triggered by user');
                        await syncService.syncPendingOperations();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Sync complete!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.sync, size: 16, color: colors.error),
                      label: Text(
                        'Sync Now',
                        style: AppTypography.bodyS.copyWith(color: colors.error),
                      ),
                    ),
                ],
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: _buildTotalGroupsCard(colors, viewModel.groups.length),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Shared Calendars',
              style: AppTypography.h4.copyWith(color: colors.onPrimary),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildGroupList(context, colors, viewModel),
            ),
          ),
        ],
      ),
      floatingActionButton: FAB(
        options: [
          FabOption(
            icon: AppIcons.add,
            label: 'Add Group',
            onPressed: () => _showAddOrUpdateGroupDialog(context, viewModel),
          ),
          // Temporary debug sync button
          FabOption(
            icon: Icons.sync,
            label: 'Force Sync (${syncService.pendingOperationsCount})',
            onPressed: () async {
              print('🔵 [DEBUG] Manual sync triggered - pending: ${syncService.pendingOperationsCount}');
              await syncService.syncPendingOperations();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Sync complete! ${syncService.pendingOperationsCount} remaining'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(BuildContext context, ColorScheme colors, SharedViewModel viewModel) {
    if (viewModel.state == ViewState.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              viewModel.isOnline 
                ? 'Loading groups from cloud...'
                : 'Loading cached groups...',
              style: AppTypography.bodyM.copyWith(color: colors.onSurface),
            ),
          ],
        ),
      );
    }
    
    if (viewModel.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load groups',
              style: AppTypography.h5.copyWith(color: colors.error),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.isOnline
                ? 'Check your connection and try again'
                : 'No cached data available',
              style: AppTypography.bodyS.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final authService = context.read<AuthService>();
                final userId = authService.currentUser?.uid;
                if (userId != null) {
                  viewModel.fetchGroups(userId);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.shared,
              size: 64,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No groups found',
              style: AppTypography.h5.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first group!',
              style: AppTypography.bodyS.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (!viewModel.isOnline) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Groups created offline will sync later',
                      style: AppTypography.bodyS.copyWith(color: colors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.groups.length,
      itemBuilder: (context, index) {
        final group = viewModel.groups[index];
        return Dismissible(
          key: Key(group.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            // Show confirmation dialog
            return await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Group'),
                  content: Text(
                    'Are you sure you want to delete "${group.name}"?${!viewModel.isOnline ? '\n\nThis will be synced when you\'re back online.' : ''}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            ) ?? false;
          },
          onDismissed: (_) {
            final deletedName = group.name;
            viewModel.deleteGroup(group.id);
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        viewModel.isOnline ? Icons.delete : Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.isOnline
                              ? '"$deletedName" deleted and syncing...'
                              : '"$deletedName" deleted locally - will sync when online',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: viewModel.isOnline 
                      ? Colors.red.shade600 
                      : Colors.orange.shade600,
                  duration: const Duration(seconds: 3),
                ),
              );
          },
          background: Container(
            color: Colors.red.shade400,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Icon(AppIcons.delete, color: Colors.white),
          ),
          child: _buildGroupListItem(context, colors, viewModel, group),
        );
      },
    );
  }
  Widget _buildGroupListItem(BuildContext context, ColorScheme colors, SharedViewModel viewModel, Group group) {
    // Debug: ver qué imageUrl tiene el grupo al renderizar
    print('🎨 [DEBUG] Rendering group ${group.id} (${group.name}) with imageUrl: ${group.imageUrl}');
    
    // Validar formato de imageUrl
    if (group.imageUrl != null && group.imageUrl!.startsWith('gs://')) {
      print('⚠️ [DEBUG] Invalid imageUrl format (gs:// instead of https://): ${group.imageUrl}');
    }
    
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GroupDetailScreenWrapper(
              groupId: group.id,
              groupName: group.name,
            ),
          ),
        );
      },
      onLongPress: () => _showAddOrUpdateGroupDialog(context, viewModel, group: group),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Avatar del grupo usando CachedNetworkImage
            // Prioridad: imagen personalizada del grupo > avatar generado por API
            CachedNetworkImage(
              imageUrl: group.imageUrl ?? 
                  'https://ui-avatars.com/api/'
                  '?name=${Uri.encodeComponent(group.name)}'
                  '&size=80'
                  '&background=random'
                  '&color=fff'
                  '&bold=true',
              imageBuilder: (context, imageProvider) => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Placeholder mientras carga la imagen
              placeholder: (context, url) => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              // Widget de error si falla la carga
              errorWidget: (context, url, error) => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.onPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                    style: TextStyle(
                      color: colors.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              // Configuración de caché para optimizar rendimiento
              // IMPORTANTE: No usar cacheKey fijo o la imagen no se refresca al cambiar
              // CachedNetworkImage usa la URL completa internamente, que incluye el token único
              // Esto garantiza que cuando la URL cambie (nuevo token), se recargue la imagen
              key: ValueKey(group.imageUrl ?? 'group_avatar_${group.id}'),
              memCacheHeight: 96,  // 2x el tamaño de display (48px) para pantallas de alta densidad
              memCacheWidth: 96,
              maxHeightDiskCache: 160,  // Tamaño máximo en disco
              maxWidthDiskCache: 160,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name, 
                          style: AppTypography.bodyM.copyWith(color: colors.onSurface)
                        ),
                      ),
                      // Sync status indicator
                      if (!viewModel.isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_off,
                                size: 10,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Cached',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.members.map((user) => user.nick).join(', '),
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyS.copyWith(color: colors.onPrimaryContainer)
                  ),
                ],
              ),
            ),
            Icon(AppIcons.arrowRight, color: colors.onPrimaryContainer, size: 16),
          ],
        ),
      ),
    );
  }
  
  // CORREGIDO: Widget implementado
  Widget _buildTotalGroupsCard(ColorScheme colors, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Groups:', style: AppTypography.h5.copyWith(color: colors.onSurface)),
          Text(count.toString(), style: AppTypography.h5.copyWith(color: colors.onSurface)),
        ],
      ),
    );
  }
  
  // Lista de avatares preset para grupos
  static const List<String> _presetGroupAvatars = [
    'assets/group_avatars/group_1.png',
    'assets/group_avatars/group_2.png',
    'assets/group_avatars/group_3.png',
    'assets/group_avatars/group_4.png',
  ];

  // NUEVO: Diálogo para Crear y Actualizar
  void _showAddOrUpdateGroupDialog(BuildContext context, SharedViewModel viewModel, {Group? group}) {
    final isUpdating = group != null;
    final nameController = TextEditingController(text: isUpdating ? group.name : '');
 
    // Lista de controladores para los campos de email
    final List<TextEditingController> emailControllers = [];
    if (isUpdating) {
      for (var member in group.members) {
        emailControllers.add(TextEditingController(text: member.email));
      }
    } else{
      emailControllers.add(TextEditingController());
    }
    
    // Si el grupo ya tiene una imageUrl, la mostramos
    final existingImageUrl = isUpdating ? group.imageUrl : null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Variables de estado DENTRO del StatefulBuilder
        String? emailError;
        String? selectedPresetAvatar;
        String? selectedGalleryPath;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Determinar qué avatar mostrar
            Widget avatarWidget;
            if (selectedGalleryPath != null) {
              // Mostrar imagen de galería
              avatarWidget = CircleAvatar(
                radius: 40,
                backgroundImage: FileImage(File(selectedGalleryPath!)),
              );
            } else if (selectedPresetAvatar != null) {
              // Mostrar preset seleccionado
              avatarWidget = CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(selectedPresetAvatar!),
              );
            } else if (existingImageUrl != null) {
              // Mostrar imagen existente
              avatarWidget = CachedNetworkImage(
                imageUrl: existingImageUrl,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 40,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => const CircleAvatar(
                  radius: 40,
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.group),
                ),
              );
            } else {
              // Avatar por defecto
              avatarWidget = const CircleAvatar(
                radius: 40,
                child: Icon(Icons.group, size: 40),
              );
            }

            return AlertDialog(
              title: Text(isUpdating ? 'Update Group' : 'Add Group'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar preview con botones
                      Center(
                        child: Column(
                          children: [
                            avatarWidget,
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.grid_view, size: 18),
                                  label: const Text('Presets'),
                                  onPressed: () async {
                                    final choice = await showModalBottomSheet<String>(
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
                                            itemCount: _presetGroupAvatars.length,
                                            itemBuilder: (c, i) {
                                              final asset = _presetGroupAvatars[i];
                                              return GestureDetector(
                                                onTap: () => Navigator.pop(c, asset),
                                                child: CircleAvatar(
                                                  backgroundImage: AssetImage(asset),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                    if (choice != null) {
                                      setDialogState(() {
                                        selectedPresetAvatar = choice;
                                        selectedGalleryPath = null;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.photo_library, size: 18),
                                  label: const Text('Upload'),
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final picked = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      maxWidth: 1080,
                                    );
                                    if (picked != null) {
                                      setDialogState(() {
                                        selectedGalleryPath = picked.path;
                                        selectedPresetAvatar = null;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Group Name')
                      ),
                      const SizedBox(height: 16),
                      const Text('Member Emails:', style: TextStyle(fontWeight: FontWeight.bold)),
                      // Usamos un ListView con altura acotada para evitar Expanded dentro de AlertDialog
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: emailControllers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: emailControllers[index],
                                      decoration: InputDecoration(hintText: 'member${index + 1}@email.com'),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                  ),
                                  // Botón para eliminar un campo de email
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () {
                                      if (emailControllers.length > 1) {
                                        final controllerToRemove = emailControllers[index];
                                        setDialogState(() {
                                          emailControllers.removeAt(index);
                                        });
                                        // Importante: eliminar el controlador después de que el widget haya sido removido del árbol
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          controllerToRemove.dispose();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Botón para añadir un nuevo campo de email
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add member'),
                          onPressed: () {
                            setDialogState(() {
                              emailControllers.add(TextEditingController());
                            });
                          },
                        ),
                      ),
                      if (emailError?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            emailError ?? '',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text;
                    // Recoger todos los emails de los controladores
                    final emails = emailControllers
                        .map((controller) => controller.text.trim())
                        .where((email) => email.isNotEmpty)
                        .toList();

                    // Validación de correos
                    final invalidEmails = emails.where((email) => !email.contains('@')).toList();
                    if (invalidEmails.isNotEmpty) {
                      setDialogState(() {
                        emailError = 'All emails must contain "@".';
                      });
                      return;
                    }

                    if (name.isEmpty || emails.isEmpty) {
                      setDialogState(() {
                        emailError = 'Por favor ingresa un nombre de grupo y al menos un correo válido.';
                      });
                      return;
                    }

                    // Cerrar dialog
                    Navigator.of(dialogContext).pop();

                    // Determinar el imageUrl y gestionar la subida
                    String? imageUrl;
                    File? fileToUpload;
                    
                    // Prioridad: galería > preset > mantener existente
                    if (selectedGalleryPath != null) {
                      // Usuario seleccionó imagen de galería
                      fileToUpload = File(selectedGalleryPath!);
                      print('📷 [DEBUG] Selected gallery image: $selectedGalleryPath');
                    } else if (selectedPresetAvatar != null) {
                      // Usuario seleccionó preset - convertir asset a File temporal
                      try {
                        final byteData = await rootBundle.load(selectedPresetAvatar!);
                        final buffer = byteData.buffer;
                        final tempDir = await getTemporaryDirectory();
                        final tempFile = File('${tempDir.path}/preset_${DateTime.now().millisecondsSinceEpoch}.png');
                        await tempFile.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
                        fileToUpload = tempFile;
                        print('🎨 [DEBUG] Converted preset to temp file: ${tempFile.path}');
                      } catch (e) {
                        print('⚠️ [DEBUG] Failed to convert preset to file: $e');
                        fileToUpload = null;
                      }
                    } else if (existingImageUrl != null) {
                      // No se seleccionó nada nuevo, mantener la imagen existente
                      imageUrl = existingImageUrl;
                      print('♻️ [DEBUG] Keeping existing imageUrl: $imageUrl');
                    }
                    
                    // Si hay archivo para subir (galería o preset), subirlo a Firebase Storage
                    if (fileToUpload != null) {
                      final groupId = isUpdating ? group.id : DateTime.now().millisecondsSinceEpoch.toString();
                      final imageService = GroupImageService();
                      
                      try {
                        // Mostrar loading
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Uploading image to Firebase Storage...'),
                                ],
                              ),
                              duration: Duration(seconds: 30),
                            ),
                          );
                        }

                        imageUrl = await imageService.uploadGroupImage(fileToUpload, groupId);
                        
                        print('📤 [DEBUG] Upload result - imageUrl: $imageUrl');
                        
                        // Cerrar loading
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        }

                        if (imageUrl == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ Firebase Storage not configured. Group created without image.\n\nEnable Storage in Firebase Console to upload images.'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('✅ Image uploaded successfully!'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Cerrar loading en caso de error
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Upload failed: ${e.toString().split(':').last.trim()}\n\nCheck Firebase Storage configuration.'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                        // Continuar sin imagen
                        imageUrl = null;
                      }
                    }

                    print('💾 [DEBUG] About to create/update group with imageUrl: $imageUrl');
                    
                    // Crear o actualizar grupo
                    if (isUpdating) {
                      await viewModel.updateGroup(group.id, name, emails, imageUrl: imageUrl);
                      // Show feedback based on connectivity
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  viewModel.isOnline ? Icons.check_circle : Icons.save,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    viewModel.isOnline
                                        ? 'Group "$name" updated and syncing...'
                                        : 'Group "$name" saved locally - will sync when online',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: viewModel.isOnline 
                                ? Colors.green.shade600 
                                : Colors.orange.shade600,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } else {
                      await viewModel.addGroup(name, emails, imageUrl: imageUrl);
                      // Show feedback based on connectivity
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  viewModel.isOnline ? Icons.check_circle : Icons.save,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    viewModel.isOnline
                                        ? 'Group "$name" created and syncing...'
                                        : 'Group "$name" saved locally - will sync when online',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: viewModel.isOnline 
                                ? Colors.green.shade600 
                                : Colors.orange.shade600,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(isUpdating ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Limpieza segura de controladores después de cerrar el diálogo
      // Ejecutamos en el siguiente frame para asegurarnos de que ya no hay dependientes montados
      WidgetsBinding.instance.addPostFrameCallback((_) {
        nameController.dispose();
        for (final c in emailControllers) {
          c.dispose();
        }
      });
    });
  }
}