import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/shared_view_model.dart';
import '../../widgets/burger_menu.dart';
import 'group_detail_screen.dart';
import '../../widgets/top_bar.dart';
import '../../services/auth_service.dart';
import '../../widgets/floating_action_button.dart';

// Wrapper para proveer el ViewModel (sin cambios)
class SharedScreenWrapper extends StatelessWidget {
  const SharedScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SharedViewModel(),
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
    // Usamos addPostFrameCallback para asegurarnos de que el contexto esté disponible
    // y para no llamar a setState o notificar a listeners durante un build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  // Nueva función para iniciar la carga de datos con el UID del usuario actual
  void _loadInitialData() {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      context.read<SharedViewModel>().fetchGroups(userId);
    } else {
      print("Error: No user is currently logged in to fetch groups.");
      // Opcional: mostrar un SnackBar o manejar el error
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SharedViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(
        title: "Shared",
        leftControlType: LeftControlType.menu,
        rightControlType: RightControlType.none,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      floatingActionButton: _buildFloatingActionButton(context, viewModel, colors),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, SharedViewModel viewModel, ColorScheme colors) {
    return FAB(
      options: [
        FabOption(
          icon: AppIcons.add,
          label: 'Add Group',
          onPressed: () => _showAddOrUpdateGroupDialog(context, viewModel),
        ),
      ],
    );
  }

  // Se pasa el contexto para el SnackBar y el ViewModel
  Widget _buildGroupList(BuildContext context, ColorScheme colors, SharedViewModel viewModel) {
    if (viewModel.state == ViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.state == ViewState.error) {
      return const Center(child: Text('Failed to load groups.'));
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
              'No groups found. Tap + to add one!',
              style: AppTypography.h5.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
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
          onDismissed: (_) {
            viewModel.deleteGroup(group.id);
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('${group.name} deleted')));
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
            Container(width: 20, height: 20, decoration: BoxDecoration(color: colors.onPrimary, shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.onPrimary)),
                  const SizedBox(height: 4),
                  Text(
                  group.members.map((user) => user.nick).join(', '), // Mapea la lista de AppUser a una lista de nicks y los une
                  overflow: TextOverflow.ellipsis, 
                  style: TextStyle(fontSize: 14, color: colors.onPrimaryContainer)
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
                      } else {
                        viewModel.addGroup(name, emails);
                      }
                      Navigator.of(dialogContext).pop();
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