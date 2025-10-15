// lib/features/groups/views/group_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/calendar_event_model.dart';
import '../../themes/app_icons.dart';
import '../../viewmodels/shared/group_detail_viewmodel.dart';
import '../../viewmodels/shared/shared_viewmodel.dart' hide ViewState;
import '../../widgets/burger_menu.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/top_bar.dart';
import '../../themes/app_typography.dart';


// Wrapper
class GroupDetailScreenWrapper extends StatelessWidget {
  final String groupId;
  final String groupName;
  const GroupDetailScreenWrapper({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupDetailViewModel(groupId: groupId),
      child: GroupDetailScreen(groupName: groupName),
    );
  }
}

class GroupDetailScreen extends StatefulWidget {
  final String groupName;
  const GroupDetailScreen({super.key, required this.groupName});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late DateTime _selectedDate;
  List<Day> _weekDays = [];
  late PageController _pageController;
  final int _initialPage = 5000;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now()); 
    _pageController = PageController(initialPage: _initialPage);
    _generateWeekDaysFor(_selectedDate);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _generateWeekDaysFor(DateTime date) {
    _weekDays = [];
    int currentDayOfWeek = date.weekday;
    DateTime firstDayOfWeek = date.subtract(Duration(days: currentDayOfWeek - 1));

    for (int i = 0; i < 7; i++) {
      final weekDay = firstDayOfWeek.add(Duration(days: i));
      _weekDays.add(
        Day(
          date: weekDay,
          shortName: DateFormat('E').format(weekDay).toUpperCase(),
          dayNumber: weekDay.day,
        )
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<GroupDetailViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(
        title: "Shared",
        leftControlType: LeftControlType.menu,
        rightControlType: RightControlType.none,
        onRightPressed: () {},
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: colors.tertiary,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(AppIcons.arrowLeft, size: 20),
                  color: colors.onTertiary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  widget.groupName,
                  style: AppTypography.h4.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildWeekSelector(colors),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                final newDate = DateUtils.dateOnly(DateTime.now()).add(Duration(days: index - _initialPage));
                if (!DateUtils.isSameDay(_selectedDate, newDate)) {
                  setState(() {
                    _selectedDate = newDate;
                    _generateWeekDaysFor(newDate);
                  });
                }
              },
              itemBuilder: (context, index) {
                final dateForPage = DateUtils.dateOnly(DateTime.now()).add(Duration(days: index - _initialPage));
                return Consumer<GroupDetailViewModel>(
                  builder: (context, vm, child) {
                    final eventsForPage = vm.getEventsForDay(dateForPage);
                    return _buildEventList(context, vm, eventsForPage, dateForPage);
                  }
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FAB(
        options: [
          FabOption(
            icon: AppIcons.add,
            label: 'New Group Event',
            onPressed: () => _showAddGroupEventDialog(context, viewModel),
          ),
        ]
      ),
    );
  }

// EN group_detail_screen.dart
Widget _buildWeekSelector(ColorScheme colors) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), // Añadido padding horizontal
    color: Colors.white,
    child: Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_left, color: colors.onPrimaryContainer),
          onPressed: () {
            _pageController.animateToPage(
              _pageController.page!.round() - 7,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays.map((day) {
              final isSelected = DateUtils.isSameDay(day.date, _selectedDate);
              // Ahora el `Expanded` está aquí, envolviendo directamente el DayItem
              return Expanded(
                child: _buildDayItem(colors, day, isSelected: isSelected, onTap: () {
                  if (!DateUtils.isSameDay(_selectedDate, day.date)) {
                    final today = DateUtils.dateOnly(DateTime.now());
                    final difference = day.date.difference(today).inDays;
                    _pageController.animateToPage(
                      _initialPage + difference, 
                      duration: const Duration(milliseconds: 400), 
                      curve: Curves.easeInOut,
                    );
                  }
                }),
              );
            }).toList(),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_right, color: colors.onPrimaryContainer),
          onPressed: () {
            _pageController.animateToPage(
              _pageController.page!.round() + 7,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    ),
  );
} 
  
  Widget _buildDayItem(ColorScheme colors, Day day, {required bool isSelected, required VoidCallback onTap}) {
  // Para que MON, TUE, WED... se muestren en varias líneas si es necesario
  final shortNameFormatted = day.shortName.replaceAllMapped(RegExp(r'.'), (match) => '${match.group(0)}\n').trim();

  return GestureDetector(
    onTap: onTap,
    // Usamos un Material para el efecto de splash (ripple) al tocar
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Para que el splash sea redondeado
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                shortNameFormatted,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? colors.onSecondary : colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  height: 1.1, // Reduce el espacio entre líneas
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 4),
              Text(
                day.dayNumber.toString(),
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? colors.onSecondary : colors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildEventList(BuildContext context, GroupDetailViewModel viewModel, List<CalendarEvent> events, DateTime forDate) {
    if (viewModel.state == ViewState.loading && events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.state == ViewState.error) {
      return const Center(child: Text('Failed to load events.'));
    }
    if (events.isEmpty) {
      return Center(child: Text('No events for ${DateFormat('MMMM d').format(forDate)}'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final startTime = DateFormat.jm().format(event.startTime);
        final endTime = DateFormat.jm().format(event.endTime);

        final canDismiss = event.type == EventType.group;

        Widget eventTile = Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: event.color, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            leading: _getIconForEventType(event.type),
            title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${event.ownerName} | $startTime - $endTime'),
            onLongPress: canDismiss 
              ? () => _showAddGroupEventDialog(context, viewModel, event: event)
              : null,
          ),
        );
        
        if (canDismiss) {
          return Dismissible(
            key: Key(event.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Are you sure you want to delete the event?'),
                    content: Text('Event: "${event.title}"'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              ) ?? false;
            },
            onDismissed: (_) {
              viewModel.deleteGroupEvent(event.id);
              ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(SnackBar(content: Text('"${event.title}" eliminado')));
            },
            background: Container(color: Colors.red.shade400, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20.0), child: const Icon(Icons.delete, color: Colors.white)),
            child: eventTile,
          );
        } else {
          return eventTile;
        }
      },
    );
  }

  Icon _getIconForEventType(EventType type) {
    switch (type) {
      case EventType.assignment: return const Icon(Icons.assignment, color: Colors.blue);
      case EventType.exam: return const Icon(Icons.school, color: Colors.red);
      case EventType.classSession: return const Icon(Icons.book, color: Colors.green);
      case EventType.group: return const Icon(Icons.group, color: Colors.orange);
      case EventType.personal:
      default: return const Icon(Icons.person, color: Colors.grey);
    }
  }
  
  void _showAddGroupEventDialog(BuildContext context, GroupDetailViewModel viewModel, {CalendarEvent? event}) {
    final isUpdating = event != null;
    final titleController = TextEditingController(text: isUpdating ? event.title : '');
    
    TimeOfDay selectedStartTime = isUpdating ? TimeOfDay.fromDateTime(event.startTime) : const TimeOfDay(hour: 12, minute: 0);
    TimeOfDay selectedEndTime = isUpdating ? TimeOfDay.fromDateTime(event.endTime) : const TimeOfDay(hour: 13, minute: 0);

    showDialog(
      context: context,
      builder: (context) {
        String errorMsg = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isUpdating ? 'Update Group Event' : 'Add Group Event for ${DateFormat('MMMM d').format(_selectedDate)}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Event Title')),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Start Time:'),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedStartTime);
                          if (picked != null) { setDialogState(() => selectedStartTime = picked); }
                        },
                        child: Text(selectedStartTime.format(context), style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('End Time:'),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedEndTime);
                          if (picked != null) { setDialogState(() => selectedEndTime = picked); }
                        },
                        child: Text(selectedEndTime.format(context), style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  if (errorMsg.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(errorMsg, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text;
                    if (title.isNotEmpty) {
                      final finalStartTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, selectedStartTime.hour, selectedStartTime.minute);
                      final finalEndTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, selectedEndTime.hour, selectedEndTime.minute);

                      // Validación de solapamiento para add y update
                      final allEvents = viewModel.getEventsForDay(_selectedDate);
                      final conflict = allEvents.any((e) {
                        // Si es edición, no comparar contra sí mismo
                        if (isUpdating && event != null && e.id == event.id) return false;
                        if (e.type == EventType.classSession || e.type == EventType.assignment || e.type == EventType.exam) {
                          final eStart = e.startTime;
                          final eEnd = e.endTime;
                          return finalStartTime.isBefore(eEnd) && finalEndTime.isAfter(eStart);
                        }
                        return false;
                      });
                      if (conflict) {
                        setDialogState(() {
                          errorMsg = 'The event is interfering with a class, assignment, or exam. Please choose another time slot.';
                        });
                        return;
                      }

                      if (isUpdating && event != null) {
                        viewModel.updateGroupEvent(event.id, title, finalStartTime, finalEndTime);
                      } else {
                        viewModel.addGroupEvent(title, finalStartTime, finalEndTime);
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
      },
    );
  }
}

// Modelo de ayuda para el selector de día
class Day {
  final DateTime date;
  final String shortName; 
  final int dayNumber;

  const Day({required this.date, required this.shortName, required this.dayNumber});
}