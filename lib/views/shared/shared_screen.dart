// lib/features/groups/views/shared_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
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
            _buildTotalGroupsCard(viewModel.groups.length),
            const SizedBox(height: 30),
            const Text('Shared Calendars', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 20),
            Expanded(child: _buildGroupList(context, viewModel)), // Pasamos el contexto
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () {},
        child: Icon(Icons.add, size: 28, color: colors.onPrimary),
      ),
    );
  }

  // Se pasa el contexto para el SnackBar y el ViewModel
  Widget _buildGroupList(BuildContext context, SharedViewModel viewModel) {
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
          child: _buildGroupListItem(context, viewModel, group),
        );
      },
    );
  }

  Widget _buildGroupListItem(BuildContext context, SharedViewModel viewModel, Group group) {
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
            Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFF2C3E50), shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                  const SizedBox(height: 4),
                  Text(group.members.join(', '), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
  
  // CORREGIDO: Widget implementado
  Widget _buildTotalGroupsCard(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Groups:', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
          Text(count.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
  
  // NUEVO: Diálogo para Crear y Actualizar
  void _showAddOrUpdateGroupDialog(BuildContext context, SharedViewModel viewModel, {Group? group}) {
    final isUpdating = group != null;
    final nameController = TextEditingController(text: isUpdating ? group.name : '');
    final membersController = TextEditingController(text: isUpdating ? group.members.join(', ') : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isUpdating ? 'Update Group' : 'Add Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Group Name', hintText: 'e.g., Family')),
              TextField(controller: membersController, decoration: const InputDecoration(labelText: 'Members', hintText: 'e.g., Ana, Juan, Luis')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final members = membersController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                if (name.isNotEmpty) {
                  if (isUpdating) {
                    viewModel.updateGroup(group.id, name, members);
                  } else {
                    viewModel.addGroup(name, members);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(isUpdating ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}