// lib/features/groups/views/group_detail_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/free_block_model.dart';
import '../../themes/app_icons.dart';
import '../../viewmodels/shared/group_detail_viewmodel.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/top_bar.dart';
import '../../themes/app_typography.dart';
import '../../data/repositories/shared_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';


// Wrapper
class GroupDetailScreenWrapper extends StatelessWidget {
  final String groupId;
  final String groupName;
  const GroupDetailScreenWrapper({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    // Obtener las dependencias del Provider
    final repository = context.read<SharedRepository>();
    final connectivity = context.read<ConnectivityManager>();
    
    return ChangeNotifierProvider(
      create: (_) => GroupDetailViewModel(
        groupId: groupId,
        repository: repository,
        connectivity: connectivity,
      ),
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
  // Configuración de timeline
  static const double _hourRowHeight = 80.0; // px por hora
  
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
                  title: const Text('Members Available'),
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
}

// Modelo de ayuda para el selector de día
class Day {
  final DateTime date;
  final String shortName; 
  final int dayNumber;

  const Day({required this.date, required this.shortName, required this.dayNumber});
}