import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/shared_view_model.dart';
import '../../widgets/burger_menu.dart';
import 'group_detail_screen.dart';
import '../../widgets/top_bar.dart';

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

class SharedScreen extends StatelessWidget {
  const SharedScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalGroupsCard(colors, viewModel.groups.length),
            const SizedBox(height: 30),
            Text('Shared Calendars', style: AppTypography.h4.copyWith(color: colors.onPrimary)),
            const SizedBox(height: 20),
            Expanded(child: _buildGroupList(context, colors, viewModel)), // Pasamos el contexto
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () => _showAddOrUpdateGroupDialog(context, viewModel),
        child: Icon(Icons.add, size: 28, color: colors.onPrimary),
      ),
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
      return const Center(child: Text('No groups found. Tap + to add one!'));
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
            child: const Icon(Icons.delete_sweep, color: Colors.white),
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
            Icon(AppIcons.arrowLeft, color: colors.onPrimaryContainer, size: 16),
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
      for (var member in group!.members) {
        emailControllers.add(TextEditingController(text: member.email));
      }
    } else{
      emailControllers.add(TextEditingController());
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isUpdating ? 'Update Group' : 'Add Group'),
              content: SizedBox(
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
                    // Usamos un ListView para la lista dinámica de campos
                    Expanded(
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
                                    // No permitir eliminar el último campo
                                    if (emailControllers.length > 1) {
                                      setDialogState(() {
                                        emailControllers[index].dispose(); // Limpiar el controlador
                                        emailControllers.removeAt(index);
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
                  ],
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

                    if (name.isNotEmpty && emails.isNotEmpty) {
                      if (isUpdating) {
                        viewModel.updateGroup(group.id, name, emails);
                      } else {
                        viewModel.addGroup(name, emails);
                      }
                      Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a group name and at least one member email.'))
                      );
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
      // Este bloque se ejecuta cuando el diálogo se cierra.
      // Es crucial para limpiar todos los controladores y evitar fugas de memoria.
      nameController.dispose();
      for (var controller in emailControllers) {
        controller.dispose();
      }
    });
  }
}