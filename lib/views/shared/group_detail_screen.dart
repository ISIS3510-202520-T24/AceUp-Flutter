import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../themes/app_icons.dart';
import '../../viewmodels/group_detail_view_model.dart';
import '../../viewmodels/shared_view_model.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/top_bar.dart';
import '../../themes/app_typography.dart';


// Wrapper para proveer el ViewModel. No necesita cambios.
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
  
  // Controlador para el PageView que permite el deslizamiento
  late PageController _pageController;
  // Usamos un número grande como página inicial para simular un scroll "infinito"
  final int _initialPage = 5000;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Inicializamos el controlador en la página que representa "hoy"
    _pageController = PageController(initialPage: _initialPage);
    _generateWeekDaysFor(_selectedDate);
  }

  @override
  void dispose() {
    _pageController.dispose(); // Es importante limpiar el controlador para evitar fugas de memoria
    super.dispose();
  }

  // Genera los 7 días de la semana para el selector superior, basado en una fecha de referencia
  void _generateWeekDaysFor(DateTime date) {
    _weekDays = [];
    int currentDayOfWeek = date.weekday; // Lunes = 1, Domingo = 7
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

  // Comprueba si dos fechas pertenecen a la misma semana del calendario
  bool _isSameWeek(DateTime date1, DateTime date2) {
    // Restamos el día de la semana para encontrar el Lunes de cada fecha
    final startOfWeek1 = date1.subtract(Duration(days: date1.weekday - 1));
    final startOfWeek2 = date2.subtract(Duration(days: date2.weekday - 1));
    // Si el Lunes es el mismo día, están en la misma semana
    return DateUtils.isSameDay(startOfWeek1, startOfWeek2);
  }

  @override
  Widget build(BuildContext context) {
    // No es necesario llamar a context.watch aquí, ya que lo pasamos a los widgets hijos
    final viewModel = context.read<GroupDetailViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(
        title: "Shared",
        leftControlType: LeftControlType.menu,
        rightControlType: RightControlType.edit,
        onRightPressed: () {
          // TODO
        },
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
                // Calculamos la nueva fecha basada en la página a la que se deslizó el usuario
                final newDate = DateTime.now().add(Duration(days: index - _initialPage));
                setState(() {
                  _selectedDate = newDate;
                  // Si el deslizamiento nos lleva a una semana diferente, regeneramos el selector
                  if (!_isSameWeek(_weekDays.first.date, newDate)) {
                    _generateWeekDaysFor(newDate);
                  }
                });
              },
              itemBuilder: (context, index) {
                // Para cada página, calculamos la fecha correspondiente
                final dateForPage = DateTime.now().add(Duration(days: index - _initialPage));
                // Usamos Consumer para que solo la lista de eventos se reconstruya al cambiar los datos
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrUpdateEventDialog(context, viewModel),
        backgroundColor: colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Icon(Icons.event, color: colors.onPrimary),
      ),
    );
  }

  Widget _buildWeekSelector(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _weekDays.map((day) {
          final isSelected = DateUtils.isSameDay(day.date, _selectedDate);
          return _buildDayItem(colors, day, isSelected: isSelected, onTap: () {
            // Al tocar un día, calculamos cuántos días de diferencia hay con hoy
            final today = DateUtils.dateOnly(DateTime.now());
            final difference = day.date.difference(today).inDays;
            // Animamos el PageView a la página correspondiente
            _pageController.animateToPage(
              _initialPage + difference, 
              duration: const Duration(milliseconds: 400), 
              curve: Curves.easeInOut,
            );
          });
        }).toList(),
      ),
    );
  }
  
  Widget _buildDayItem(ColorScheme colors, Day day, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(day.shortName, style: TextStyle(fontSize: 12, color: colors.onPrimaryContainer, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(day.dayNumber.toString(), style: TextStyle(fontSize: 18, color: colors.onSurfaceVariant, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(BuildContext context, GroupDetailViewModel viewModel, List<Event> events, DateTime forDate) {
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
        final startTime = DateFormat.jm().format(event.startTime.toDate());
        final endTime = DateFormat.jm().format(event.endTime.toDate());

        return Dismissible(
          key: Key(event.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            viewModel.deleteEvent(event.id);
            ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(SnackBar(content: Text('${event.title} deleted')));
          },
          background: Container(color: Colors.red.shade400, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20.0), child: const Icon(Icons.delete, color: Colors.white)),
          child: Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            color: const Color(0xFFF0FAF8),
            child: ListTile(
              title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Time: $startTime - $endTime'),
              onTap: () => _showAddOrUpdateEventDialog(context, viewModel, event: event),
            ),
          ),
        );
      },
    );
  }
  
  void _showAddOrUpdateEventDialog(BuildContext context, GroupDetailViewModel viewModel, {Event? event}) {
    final isUpdating = event != null;
    final titleController = TextEditingController(text: isUpdating ? event.title : '');
    
    TimeOfDay selectedStartTime = isUpdating ? TimeOfDay.fromDateTime(event.startTime.toDate()) : const TimeOfDay(hour: 12, minute: 0);
    TimeOfDay selectedEndTime = isUpdating ? TimeOfDay.fromDateTime(event.endTime.toDate()) : const TimeOfDay(hour: 13, minute: 0);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isUpdating ? 'Update Event' : 'Add Event for ${DateFormat('MMMM d').format(_selectedDate)}'),
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
                          if (picked != null && picked != selectedStartTime) {
                            setDialogState(() {
                              selectedStartTime = picked;
                            });
                          }
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
                          if (picked != null && picked != selectedEndTime) {
                            setDialogState(() {
                              selectedEndTime = picked;
                            });
                          }
                        },
                        child: Text(selectedEndTime.format(context), style: const TextStyle(fontSize: 16)),
                      ),
                    ],
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

                      if (isUpdating) {
                        viewModel.updateEvent(event.id, title, finalStartTime, finalEndTime);
                      } else {
                        viewModel.addEvent(title, finalStartTime, finalEndTime);
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