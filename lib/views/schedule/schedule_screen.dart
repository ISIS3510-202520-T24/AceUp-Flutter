import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/schedule_event.dart';
import '../../services/schedule_repository.dart';
import '../../widgets/weekly_calendar_view.dart';
import 'manual_schedule_edit_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ScheduleRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header con título y botón de añadir manual
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add manual'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ManualScheduleEditScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Classes from Monday to Friday (7:00 a.m. – 10:00 p.m.)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: WeeklyCalendarView(
              events: repo.events,
              onEventTap: (event) {
                _showEventDetails(context, event);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showEventDetails(BuildContext context, ScheduleEvent event) {
    final repo = context.read<ScheduleRepository>();

    final startTime = _formatTime(event.startMinutes);
    final endTime = _formatTime(event.endMinutes);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la clase
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              // Día y hora
              Text(
                '${_weekdayLabel(event.weekday)} • $startTime – $endTime',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Location: ${event.location!}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
              if (event.professor != null && event.professor!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Professor: ${event.professor!}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  // 🔹 EDITAR CLASE
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit class'),
                      onPressed: () {
                        // 1) Cerramos el bottom sheet
                        Navigator.of(ctx).pop();

                        // 2) Eliminamos esta instancia del horario
                        repo.removeEvent(event.id);

                        // 3) Abrimos el editor manual con la clase precargada
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ManualScheduleEditScreen(
                              initialDrafts: [event],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 🔥 ELIMINAR TODA LA CLASE (todas las instancias con ese título)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete course'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        repo.deleteEventsByTitle(event.title);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _formatTime(int minutes) {
    var h = minutes ~/ 60;
    final m = minutes % 60;
    final isAm = h < 12;
    var displayH = h % 12;
    if (displayH == 0) displayH = 12;
    final suffix = isAm ? 'a.m.' : 'p.m.';
    final mm = m.toString().padLeft(2, '0');
    return '$displayH:$mm $suffix';
  }
}
