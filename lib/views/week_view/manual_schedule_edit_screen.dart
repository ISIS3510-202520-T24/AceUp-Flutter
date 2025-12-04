import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/schedule_event.dart';
import '../../data/repositories/academic_repository.dart';

class ManualScheduleEditScreen extends StatefulWidget {
  const ManualScheduleEditScreen({
    super.key,
    this.initialDrafts = const [],
  });

  /// Eventos sugeridos por la IA que llegan como borradores (actualmente no se usa).
  final List<ScheduleEvent> initialDrafts;

  @override
  State<ManualScheduleEditScreen> createState() =>
      _ManualScheduleEditScreenState();
}

class _ScheduleDraft {
  String title;
  Set<int> weekdays; // puede tener varios días
  String startText; // "08:00"
  String endText; // "10:00"
  String location;
  String professor;

  _ScheduleDraft({
    required this.title,
    required this.weekdays,
    required this.startText,
    required this.endText,
    this.location = '',
    this.professor = '',
  });
}

class _ManualScheduleEditScreenState extends State<ManualScheduleEditScreen> {
  final List<_ScheduleDraft> _drafts = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialDrafts.isNotEmpty) {
      // Versión simple: cada evento de initialDrafts se vuelve un draft
      for (final e in widget.initialDrafts) {
        _drafts.add(
          _ScheduleDraft(
            title: e.title,
            weekdays: {e.weekday},
            startText: _minutesToText(e.startMinutes),
            endText: _minutesToText(e.endMinutes),
            location: e.location ?? '',
            professor: e.professor ?? '',
          ),
        );
      }
    } else {
      _drafts.add(
        _ScheduleDraft(
          title: '',
          weekdays: {DateTime.monday},
          startText: '08:00',
          endText: '10:00',
        ),
      );
    }
  }

  static String _minutesToText(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  int? _parseTimeToMinutes(String text) {
    final trimmed = text.trim();
    if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(trimmed)) return null;

    final parts = trimmed.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;

    return h * 60 + m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit schedule'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _drafts.length,
              itemBuilder: (context, index) {
                final draft = _drafts[index];
                return _buildDraftCard(context, draft, index);
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      if (_drafts.length >= 14) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You can have up to 14 classes.'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _drafts.add(
                          _ScheduleDraft(
                            title: '',
                            weekdays: {DateTime.monday},
                            startText: '08:00',
                            endText: '10:00',
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add class'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _onSavePressed(),
                    icon: const Icon(Icons.check),
                    label: const Text('Save to calendar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftCard(
      BuildContext context, _ScheduleDraft draft, int index) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Class ${index + 1}',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                if (_drafts.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _drafts.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            TextFormField(
              initialValue: draft.title,
              decoration: const InputDecoration(labelText: 'Class title'),
              onChanged: (value) {
                draft.title = value;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Days',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: _buildDayChips(draft),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: draft.startText,
                    decoration: const InputDecoration(
                      labelText: 'Start (HH:mm)',
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (value) {
                      draft.startText = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: draft.endText,
                    decoration: const InputDecoration(
                      labelText: 'End (HH:mm)',
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (value) {
                      draft.endText = value;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: draft.location,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
              ),
              onChanged: (value) {
                draft.location = value;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: draft.professor,
              decoration: const InputDecoration(
                labelText: 'Professor (optional)',
              ),
              onChanged: (value) {
                draft.professor = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDayChips(_ScheduleDraft draft) {
    const days = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];
    const labels = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return List.generate(days.length, (i) {
      final day = days[i];
      final label = labels[i];
      final selected = draft.weekdays.contains(day);

      return FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (value) {
          setState(() {
            if (value) {
              draft.weekdays.add(day);
            } else {
              draft.weekdays.remove(day);
            }
            if (draft.weekdays.isEmpty) {
              draft.weekdays.add(DateTime.monday);
            }
          });
        },
      );
    });
  }

  Future<void> _onSavePressed() async {
    final repo = context.read<ScheduleRepository>();
    final now = DateTime.now().millisecondsSinceEpoch;

    final events = <ScheduleEvent>[];

    for (var i = 0; i < _drafts.length; i++) {
      final draft = _drafts[i];
      final title = draft.title.trim();
      if (title.isEmpty) continue;

      final startMinutes = _parseTimeToMinutes(draft.startText);
      final endMinutes = _parseTimeToMinutes(draft.endText);

      if (startMinutes == null || endMinutes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please use time format HH:mm (e.g. 08:00).'),
          ),
        );
        return;
      }

      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time.'),
          ),
        );
        return;
      }

      final loc = draft.location.trim();
      final prof = draft.professor.trim();

      final String? locField = loc.isEmpty ? null : loc;
      final String? profField = prof.isEmpty ? null : prof;

      for (final day in draft.weekdays) {
        events.add(
          ScheduleEvent(
            id: '${now}_${i}_$day',
            title: title,
            weekday: day,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
            location: locField,
            professor: profField,
            source: ScheduleSource.manual,
            kind: ScheduleKind.classEvent,
          ),
        );
      }
    }

    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one class')),
      );
      return;
    }

    // 🔍 Buscar clases que se solapan con las nuevas
    final conflicts = repo.findConflicts(events);

    if (conflicts.isNotEmpty) {
      final replace = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Overlapping classes'),
              content: Text(
                'You already have ${conflicts.length} class(es) at that time.\n\n'
                'Do you want to replace them with this new schedule?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Replace'),
                ),
              ],
            ),
          ) ??
          false;

      if (!replace) {
        // Usuario canceló, no guardamos nada
        return;
      }

      // Reemplazamos las clases que chocan
      repo.replaceConflictingEvents(events);
    } else {
      // No hay conflictos, simplemente añadimos
      repo.addEvents(events);
    }

    Navigator.of(context).pop();
  }
}
