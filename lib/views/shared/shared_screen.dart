import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class SharedScreenWrapper extends StatelessWidget {
  const SharedScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener las dependencias del Provider
    final repository = context.read<SharedRepository>();
    final connectivity = context.read<ConnectivityManager>();
    
    return ChangeNotifierProvider(
      create: (_) => SharedViewModel(
        repository: repository,
        connectivity: connectivity,
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
            Container(
              width: 20, 
              height: 20, 
              decoration: BoxDecoration(
                color: colors.onPrimary, 
                shape: BoxShape.circle
              )
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

    showDialog(
      context: context,
      builder: (dialogContext) {
        String? emailError;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isUpdating ? 'Update Group' : 'Add Group'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                  onPressed: () {
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

                    if (name.isNotEmpty && emails.isNotEmpty) {
                      if (isUpdating) {
                        viewModel.updateGroup(group.id, name, emails);
                        Navigator.of(dialogContext).pop();
                        // Show feedback based on connectivity
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
                      } else {
                        viewModel.addGroup(name, emails);
                        Navigator.of(dialogContext).pop();
                        // Show feedback based on connectivity
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
                    } else {
                      setDialogState(() {
                        emailError = 'Por favor ingresa un nombre de grupo y al menos un correo válido.';
                      });
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