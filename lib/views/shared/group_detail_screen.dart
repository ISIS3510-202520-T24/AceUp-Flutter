// lib/features/groups/views/group_detail_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/calendar_event_model.dart';
import '../../models/free_block_model.dart';
import '../../themes/app_icons.dart';
import '../../viewmodels/shared/group_detail_viewmodel.dart';
import '../../widgets/burger_menu.dart';
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
  // Devuelve el lunes de la semana de la fecha dada
  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
  late DateTime _selectedDate;
  late DateTime _weekStartDate; // lunes de la semana actual
  List<Day> _weekDays = [];
  Timer? _nowTimer; // para actualizar la línea de "ahora"
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
  _selectedDate = DateUtils.dateOnly(DateTime.now());
  _weekStartDate = _getMonday(_selectedDate);
  _generateWeekDaysFor(_weekStartDate);
  // Actualizar la línea de la hora actual cada minuto
  _now = DateTime.now();
  _nowTimer = Timer.periodic(const Duration(minutes: 1), (_) {
    if (!mounted) return;
    setState(() {
      _now = DateTime.now();
    });
  });
  }

  @override
  void dispose() {
  _nowTimer?.cancel();
  super.dispose();
  }

  void _generateWeekDaysFor(DateTime date) {
    _weekDays = [];
    // Solo lunes a viernes
    for (int i = 0; i < 5; i++) {
      final weekDay = date.add(Duration(days: i));
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
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < 0) {
            // Swipe left: next week
            setState(() {
              _weekStartDate = _weekStartDate.add(const Duration(days: 7));
              _generateWeekDaysFor(_weekStartDate);
            });
          } else if (details.primaryVelocity! > 0) {
            // Swipe right: previous week
            setState(() {
              _weekStartDate = _weekStartDate.subtract(const Duration(days: 7));
              _generateWeekDaysFor(_weekStartDate);
            });
          }
        },
        child: Column(
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
              child: Consumer<GroupDetailViewModel>(
                builder: (context, vm, child) {
                  return _buildGroupAvailabilityGrid(vm);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
      // Grilla semanal tipo timeline (Lun-Vie). Días en columnas y tiempo en el eje Y.
      Widget _buildGroupAvailabilityGrid(GroupDetailViewModel vm) {
        // Configuración visual y de tiempo
    const int startHour = 6; // 6 AM
    const int endHour = 21;  // 9 PM
    const int intervalMinutes = 30;
    // Solo lunes a viernes de la semana seleccionada
    final days = List.generate(5, (i) => _weekStartDate.add(Duration(days: i)));

    // Altura total del timeline
    final double pxPerMinute = _hourRowHeight / 60.0;
    final double totalHeight = (endHour - startHour) * 60 * pxPerMinute;

    // Unir bloques consecutivos con los mismos miembros para limpiar la vista
    final mergedByDay = _mergeFreeBlocksByDay(vm.groupFreeBlocks, intervalMinutes, days);

    // Preparativos para resaltar el día actual y dibujar la línea de la hora actual
    final DateTime now = _now;
    final bool isTodayInView = days.any((d) => DateUtils.isSameDay(d, now));
    final int nowMinutesOfDay = now.hour * 60 + now.minute;
    final bool isNowInRange = nowMinutesOfDay >= startHour * 60 && nowMinutesOfDay <= endHour * 60;
    double nowTop = (nowMinutesOfDay - startHour * 60) * pxPerMinute;
    if (nowTop.isNaN) nowTop = 0;
    nowTop = nowTop.clamp(0.0, totalHeight);

    // Timeline sin cabecera duplicada (usamos el selector de semana arriba)
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Columna de horas
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    for (int h = startHour; h < endHour; h++)
                      SizedBox(
                        height: _hourRowHeight,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6.0, top: 2),
                            child: Text(
                              DateFormat('ha').format(DateTime(0, 1, 1, h)).toLowerCase(),
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
                const SizedBox(width: 4),
              // Área de columnas por día
              Expanded(
                child: Row(
                  children: [
                    for (int i = 0; i < days.length; i++)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: Stack(
                            children: [
                              // Fondo + líneas por hora
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                ),
                              ),
                              ...List.generate(endHour - startHour, (idx) {
                                final top = idx * _hourRowHeight;
                                return Positioned(
                                  top: top,
                                  left: 0,
                                  right: 0,
                                  child: Container(height: 1, color: Colors.black12),
                                );
                              }),
                              // Bloques de disponibilidad para el día i (weekday days[i])
                              ...[
                                for (final b in (mergedByDay[days[i]] ?? const <FreeBlock>[]))
                                  if (b.freeMembers.isNotEmpty)
                                    _buildPositionedFreeBlock(b, startHour, endHour, pxPerMinute)
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
                ],
              ),
              // Línea de tiempo actual (desde la columna de horas hasta el extremo derecho)
              if (isTodayInView && isNowInRange)
                Positioned(
                  top: nowTop,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para construir el selector de semana
  Widget _buildWeekSelector(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna de horas vacía para alinear con el grid
          SizedBox(width: 50),
          const SizedBox(width: 4),
          // Días alineados exactamente con las columnas de bloques
          Expanded(
            child: Row(
              children: List.generate(5, (i) {
                final day = _weekDays[i];
                final isToday = DateUtils.isSameDay(day.date, DateTime.now());
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateUtils.dateOnly(day.date);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isToday ? scheme.primary.withOpacity(0.22) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: scheme.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(day.shortName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(day.dayNumber.toString(),
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

      // Devuelve un mapa de día de semana -> lista de FreeBlocks ya fusionados por día
  // Une bloques consecutivos con los mismos miembros para cada día visible
  Map<DateTime, List<FreeBlock>> _mergeFreeBlocksByDay(List<FreeBlock> blocks, int intervalMinutes, List<DateTime> days) {
    final map = <DateTime, List<FreeBlock>>{};
    for (final day in days) {
      // Filtrar bloques por el día de la semana (weekday)
      final dayBlocks = blocks
          .where((b) => b.weekday == day.weekday && b.freeMembers.isNotEmpty)
          .toList()
        ..sort((a, b) => _toMinutes(a.start).compareTo(_toMinutes(b.start)));

      final merged = <FreeBlock>[];
      for (final b in dayBlocks) {
        if (merged.isEmpty) {
          merged.add(b);
          continue;
        }
        final last = merged.last;
        final contiguous = _toMinutes(b.start) == _toMinutes(last.end);
        final samePeople = _sameMembers(last.freeMembers, b.freeMembers);
        if (contiguous && samePeople) {
          // extender el último
          merged[merged.length - 1] = FreeBlock(
            weekday: last.weekday,
            start: last.start,
            end: b.end,
            freeMembers: last.freeMembers,
          );
        } else {
          merged.add(b);
        }
      }
      map[day] = merged;
    }
    return map;
  }

  // Convierte TimeOfDay a minutos
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  // Compara listas de miembros
  bool _sameMembers(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sa = [...a]..sort();
    final sb = [...b]..sort();
    for (int i = 0; i < sa.length; i++) {
      if (sa[i] != sb[i]) return false;
    }
    return true;
  }

  // Mapea cantidad de personas libres a un color
  Color _colorForCount(int count) {
    if (count <= 2) return Colors.indigo;
    if (count <= 4) return Colors.purple;
    return Colors.teal;
  }


  // Widget para el header de días
  Widget _buildDayItem(ColorScheme colors, Day day, {required bool isSelected, required bool isToday, required VoidCallback onTap}) {
    final shortNameFormatted = day.shortName;
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isToday ? colors.primary.withOpacity(0.22) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(color: colors.primary.withOpacity(0.45), width: 1)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    shortNameFormatted,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? colors.onSecondary : colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
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
          ],
        ),
      ),
    );
  }

      // Construye el widget posicionado para un FreeBlock ya fusionado
      Positioned _buildPositionedFreeBlock(FreeBlock b, int startHour, int endHour, double pxPerMinute) {
        final startMins = (_toMinutes(b.start) - startHour * 60).clamp(0, (endHour - startHour) * 60);
        final endMins = (_toMinutes(b.end) - startHour * 60).clamp(0, (endHour - startHour) * 60);
        final height = ((endMins - startMins) * pxPerMinute).toDouble();
        final top = startMins * pxPerMinute;
        final colors = _colorForCount(b.freeMembers.length);
        final label = b.freeMembers.join(', ');
        return Positioned(
          top: top,
          left: 4,
          right: 4,
          height: height <= 0 ? 1 : height,
          child: GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Block members'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final member in b.freeMembers)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(member, style: const TextStyle(fontSize: 16)),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 1),
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: colors.withOpacity(0.25),
                border: Border.all(color: colors, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      }

  // Removed old list view implementation in favor of timeline layout

  Icon _getIconForEventType(EventType type) {
    switch (type) {
      case EventType.assignment: return const Icon(Icons.assignment, color: Colors.blue);
      case EventType.exam: return const Icon(Icons.school, color: Colors.red);
      case EventType.classSession: return const Icon(Icons.book, color: Colors.green);
      case EventType.group: return const Icon(Icons.group, color: Colors.orange);
      case EventType.personal:
        return const Icon(Icons.person, color: Colors.grey);
    }
  }
  
  // ===================
  // Day timeline layout
  // ===================
  static const int _startHour = 6;   // 6 AM
  static const int _startMinute = 0; // Start exactly at 6:00 AM
  static const int _endHour = 24;    // 12 AM (midnight)
  static const double _hourRowHeight = 80.0; // px per hour (increased for better spacing)
  static const double _minEventHeight = 40.0; // minimum height for events
  static const double _laneGap = 4.0; // gap between overlapping columns
  static const double _timelinePadding = 4.0; // padding inside the timeline area

  double get _timelineHeight => ((_endHour - _startHour) * 60 - _startMinute) / 60.0 * _hourRowHeight;

  // ignore: unused_element
  Widget _buildDayTimeline(BuildContext context, GroupDetailViewModel vm, List<CalendarEvent> events, DateTime date) {
    // Generate time labels from 6:00 AM to 11:00 PM (one label per hour row)
    final timeLabels = List<String>.generate(
      _endHour - _startHour,
      (i) => DateFormat('ha')
          .format(DateTime(date.year, date.month, date.day, _startHour + i))
          .toLowerCase(),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        height: _timelineHeight,
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hour labels column
        SizedBox(
          width: 60,
          child: Column(
            children: [
              for (int i = 0; i < timeLabels.length; i++)
                SizedBox(
                  height: _hourRowHeight,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 2),
                      child: Text(
                        timeLabels[i],
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Timeline area
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final positioned = _layoutEventsForDay(events, totalWidth);

              return Stack(
                children: [
                  // Grid background with hour lines
                  Container(
                    height: _timelineHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  // Hour horizontal lines
                  ...List.generate(_endHour - _startHour + 1, (i) {
                    final top = i * _hourRowHeight;
                    return Positioned(
                      top: top,
                      left: 0,
                      right: 0,
                      child: Container(height: 1, color: Colors.black12),
                    );
                  }),
                  // Events blocks
                  ...positioned.map((b) {
                    return Positioned(
                      top: b.top,
                      left: b.left,
                      width: b.width,
                      height: b.height,
                      child: _buildEventBlock(context, vm, b.event),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    )));
  }

  Widget _buildEventBlock(BuildContext context, GroupDetailViewModel vm, CalendarEvent e) {
    final canDismiss = e.type == EventType.group;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(0),
        color: e.color.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: e.color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onLongPress: canDismiss ? () => _showAddGroupEventDialog(context, vm, event: e) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_getIconForEventType(e.type).icon, size: 16, color: e.color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        e.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: e.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${e.ownerName} | ${DateFormat.jm().format(e.startTime)} - ${DateFormat.jm().format(e.endTime)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Lay out events into columns (lanes) when overlapping, and compute pixel geometry
  List<_PositionedEvent> _layoutEventsForDay(List<CalendarEvent> events, double totalWidth) {
    if (events.isEmpty) return <_PositionedEvent>[];
    
    // Use the first event's date, or DateTime.now() if empty
    final referenceDate = events.isNotEmpty 
        ? DateUtils.dateOnly(events.first.startTime)
        : DateUtils.dateOnly(DateTime.now());
    
    // Convert to internal layout items
    final items = events.map((e) => _LayoutItem(event: e)).toList();
    items.sort((a, b) => a.event.startTime.compareTo(b.event.startTime));

  final active = <_LayoutItem>[]; // currently overlapping
  var cluster = <_LayoutItem>[]; // current cluster of overlaps
    int clusterMaxCols = 0;

    void endCluster() {
      if (cluster.isEmpty) return;
      for (final it in cluster) {
        it.totalColumns = clusterMaxCols == 0 ? 1 : clusterMaxCols;
      }
      cluster = <_LayoutItem>[];
      clusterMaxCols = 0;
    }

    for (final it in items) {
      // Remove no longer overlapping from active
      active.removeWhere((a) => a.event.endTime.isBefore(it.event.startTime) || a.event.endTime.isAtSameMomentAs(it.event.startTime));

      // Assign smallest available column index
      final used = active.map((a) => a.column).toSet();
      int col = 0;
      while (used.contains(col)) {
        col++;
      }
      it.column = col;
      active.add(it);
      cluster.add(it);
      clusterMaxCols = clusterMaxCols < col + 1 ? col + 1 : clusterMaxCols;

      // If cluster ends (no active overlaps after this ends with next start), we'll finalize in next loop
      // We detect cluster end when the next item doesn't overlap current active set. We'll handle it after loop as well.
    }
    // finalize last cluster
    endCluster();

    // total columns per cluster were not set because we didn't mark cluster boundaries during loop. Fix by recomputing per overlapping group.
    // Simple second pass: for each item, compute how many columns overlap with it within items.
    for (final it in items) {
      int maxCol = 0;
      for (final other in items) {
        final overlap = it.event.startTime.isBefore(other.event.endTime) && it.event.endTime.isAfter(other.event.startTime);
        if (overlap) {
          if (other.column > maxCol) maxCol = other.column;
        }
      }
      it.totalColumns = (maxCol + 1).clamp(1, 10); // cap columns
    }

    // Geometry
    final contentWidth = totalWidth - _timelinePadding * 2;
    final pxPerMinute = _hourRowHeight / 60.0;

    List<_PositionedEvent> out = [];
    final dayStart = DateTime(referenceDate.year, referenceDate.month, referenceDate.day, _startHour, _startMinute);
    final dayEnd = DateTime(referenceDate.year, referenceDate.month, referenceDate.day + 1, 0, 0); // Midnight next day
    
    for (final it in items) {
      final e = it.event;
      final start = e.startTime;
      final end = e.endTime.isAfter(start) ? e.endTime : start.add(const Duration(minutes: 15));
      
      // Clamp to visible window (6:30 AM to 12:00 AM)
      final visibleStart = dayStart.isAfter(start) ? dayStart : start;
      final visibleEnd = dayEnd.isBefore(end) ? dayEnd : end;
      
      // Calculate position from 6:30 AM
      final minutesFromStart = visibleStart.difference(dayStart).inMinutes;
      final durationMinutes = visibleEnd.difference(visibleStart).inMinutes;

      final top = minutesFromStart * pxPerMinute;
      final height = (durationMinutes * pxPerMinute).clamp(_minEventHeight, 10000.0);

      final columns = it.totalColumns.clamp(1, 10);
      final totalGaps = (columns - 1) * _laneGap;
      final availableWidth = contentWidth - totalGaps;
      final laneWidth = availableWidth / columns;
      final left = _timelinePadding + it.column * (laneWidth + _laneGap);

      out.add(_PositionedEvent(
        event: e,
        top: top,
        left: left,
        width: laneWidth,
        height: height,
      ));
    }

    return out;
  }

  // Internal helpers moved to top-level (below)
  
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

                      // Validación de solapamiento usando el ViewModel
                      final conflictMsg = viewModel.validateEventSlot(
                        _selectedDate,
                        finalStartTime,
                        finalEndTime,
                        ignoreEventId: isUpdating ? event.id : null,
                      );
                      if (conflictMsg != null) {
                        setDialogState(() {
                          errorMsg = conflictMsg;
                        });
                        return;
                      }

                      if (isUpdating) {
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

// ===== Timeline layout helpers (top-level) =====
class _LayoutItem {
  final CalendarEvent event;
  int column = 0;
  int totalColumns = 1;
  _LayoutItem({required this.event});
}

class _PositionedEvent {
  final CalendarEvent event;
  final double top;
  final double left;
  final double width;
  final double height;
  const _PositionedEvent({
    required this.event,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });
}