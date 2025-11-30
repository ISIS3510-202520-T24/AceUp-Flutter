import 'dart:math';
import 'package:flutter/material.dart';

import '../models/schedule_event.dart';

/// Weekly calendar Monday–Friday, 7:00 a.m. – 10:00 p.m.
/// - Scroll vertical (horas)
/// - Colores por curso (máx 14 colores, se reusan si hay más)
/// - Tap en una clase => callback [onEventTap]
class WeeklyCalendarView extends StatelessWidget {
  WeeklyCalendarView({
    Key? key,
    required this.events,
    this.onEventTap,
  }) : super(key: key);

  final List<ScheduleEvent> events;
  final void Function(ScheduleEvent event)? onEventTap;

  // 7:00 a.m. – 22:00 (10 p.m.)
  static const int _kStartMinutes = 7 * 60;
  static const int _kEndMinutes = 22 * 60;

  // Altura de cada bloque de una hora en la grilla
  static const double _kHourRowHeight = 64.0;

  // Ancho de la columna de horas
  static const double _kTimeColumnWidth = 56.0;

  // Ancho aproximado de cada día (el Row padre tiene Expanded, así que se adapta)
  static const double _kDayColumnWidth = 96.0;

  // Altura mínima de un bloque de clase para evitar overflow del contenido
  static const double _kEventMinHeight = 72.0;

  // Paleta de hasta 14 colores distinta por curso
  static const List<Color> _palette = [
    Color(0xfff48fb1),
    Color(0xffce93d8),
    Color(0xffb39ddb),
    Color(0xff9fa8da),
    Color(0xff90caf9),
    Color(0xff81d4fa),
    Color(0xff80deea),
    Color(0xff80cbc4),
    Color(0xffa5d6a7),
    Color(0xffc5e1a5),
    Color(0xffffe082),
    Color(0xffffcc80),
    Color(0xffffab91),
    Color(0xffbcaaa4),
  ];

  // Mapa interno curso -> color
  final Map<String, Color> _courseColorMap = {};

  Color _colorForTitle(String title) {
    final key = title.toLowerCase().trim();
    if (_courseColorMap.containsKey(key)) {
      return _courseColorMap[key]!;
    }
    final color = _palette[_courseColorMap.length % _palette.length];
    _courseColorMap[key] = color;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    // Número de horas que vamos a mostrar
    final hourCount =
        ((_kEndMinutes - _kStartMinutes) / 60).ceil(); // 15 horas (7–22)

    final totalHeight = hourCount * _kHourRowHeight;

    // Agrupar eventos por día (solo lunes a viernes)
    final Map<int, List<ScheduleEvent>> byDay = {
      DateTime.monday: [],
      DateTime.tuesday: [],
      DateTime.wednesday: [],
      DateTime.thursday: [],
      DateTime.friday: [],
    };

    for (final e in events) {
      if (byDay.containsKey(e.weekday)) {
        byDay[e.weekday]!.add(e);
      }
    }

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          height: totalHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeColumn(hourCount),
              Expanded(
                child: Row(
                  children: [
                    _buildDayColumn(
                      context,
                      label: 'Mon',
                      weekday: DateTime.monday,
                      events: byDay[DateTime.monday]!,
                    ),
                    _buildDayColumn(
                      context,
                      label: 'Tue',
                      weekday: DateTime.tuesday,
                      events: byDay[DateTime.tuesday]!,
                    ),
                    _buildDayColumn(
                      context,
                      label: 'Wed',
                      weekday: DateTime.wednesday,
                      events: byDay[DateTime.wednesday]!,
                    ),
                    _buildDayColumn(
                      context,
                      label: 'Thu',
                      weekday: DateTime.thursday,
                      events: byDay[DateTime.thursday]!,
                    ),
                    _buildDayColumn(
                      context,
                      label: 'Fri',
                      weekday: DateTime.friday,
                      events: byDay[DateTime.friday]!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Columna izquierda con las horas (7 a.m., 8 a.m., ...)
  Widget _buildTimeColumn(int hourCount) {
    final children = <Widget>[];

    var currentHour = (_kStartMinutes / 60).floor(); // 7
    for (var i = 0; i < hourCount; i++) {
      final label = _formatHourLabel(currentHour);
      children.add(
        SizedBox(
          height: _kHourRowHeight,
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
      currentHour++;
    }

    return SizedBox(
      width: _kTimeColumnWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: children,
      ),
    );
  }

  String _formatHourLabel(int hour24) {
    final isAm = hour24 < 12;
    var h = hour24 % 12;
    if (h == 0) h = 12;
    final suffix = isAm ? 'a.m.' : 'p.m.';
    return '$h $suffix';
  }

  Widget _buildDayColumn(
    BuildContext context, {
    required String label,
    required int weekday,
    required List<ScheduleEvent> events,
  }) {
    return Expanded(
      child: Container(
        width: _kDayColumnWidth,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          children: [
            // header con nombre del día
            SizedBox(
              height: 28,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentHeight = constraints.maxHeight;
                  final totalMinutes = _kEndMinutes - _kStartMinutes;
                  final pixelsPerMinute =
                      contentHeight / totalMinutes.toDouble();

                  final background = _buildHourGrid(contentHeight);

                  final tiles = <Widget>[];

                  for (final e in events) {
                    final startMinutes = max(e.startMinutes, _kStartMinutes);
                    final endMinutes = min(e.endMinutes, _kEndMinutes);

                    final top = (startMinutes - _kStartMinutes) *
                        pixelsPerMinute.toDouble();

                    final computedHeight =
                        (endMinutes - startMinutes) * pixelsPerMinute.toDouble();

                    final height =
                        max(_kEventMinHeight, computedHeight.roundToDouble());

                    tiles.add(
                      Positioned(
                        top: top,
                        left: 4,
                        right: 4,
                        height: height,
                        child: GestureDetector(
                          onTap: () {
                            if (onEventTap != null) {
                              onEventTap!(e);
                            }
                          },
                          child: _buildEventTile(context, e),
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      background,
                      ...tiles,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grilla de horas de fondo (solo líneas suaves horizontales)
  Widget _buildHourGrid(double totalHeight) {
    final hourCount =
        ((_kEndMinutes - _kStartMinutes) / 60).ceil(); // 15 bloques
    return Column(
      children: List.generate(
        hourCount,
        (index) => Container(
          height: totalHeight / hourCount,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade200,
                width: 0.7,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tile de una clase (texto más grande ahora)
  Widget _buildEventTile(BuildContext context, ScheduleEvent e) {
  final color = _colorForTitle(e.title);
  final textColor =
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? Colors.white
          : Colors.black87;

  return Container(
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: color.withOpacity(0.95),
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          e.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,          // 🔹 letra grande
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: textColor,
          ),
        ),
      ),
    ),
  );
}

  }
