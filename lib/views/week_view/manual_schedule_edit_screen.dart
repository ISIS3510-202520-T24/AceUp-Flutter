import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; //ignore: uri_does_not_exist

import '../../core/constants/enums.dart';
import '../../models/schedule_event.dart';
import '../../models/planner/term_model.dart';
import '../../models/planner/subject_model.dart';
import '../../models/planner/class_template_model.dart';
import '../../models/helpers/recurrence_model.dart';
import '../../models/helpers/weight_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';

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
    final repo = context.read<AcademicRepository>();
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in')),
      );
      return;
    }

    // Validate all drafts first
    for (var draft in _drafts) {
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
    }

    // Get or create active term
    final terms = await repo.getTermsForUser(userId);
    Term? activeTerm = terms.where((t) => t.isActive).firstOrNull;

    if (activeTerm == null) {
      // Create a default term
      final now = DateTime.now();
      activeTerm = Term(
        id: const Uuid().v4(), //ignore: creation_with_non_type
        name: 'AI Imported Schedule',
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 6, 30),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      await repo.saveTerm(activeTerm, userId);
    }

    // Group drafts by title (each unique title becomes a subject)
    final Map<String, List<_ScheduleDraft>> subjectGroups = {};
    for (var draft in _drafts) {
      final title = draft.title.trim();
      if (title.isEmpty) continue;
      subjectGroups.putIfAbsent(title, () => []).add(draft);
    }

    if (subjectGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one class')),
      );
      return;
    }

    // Create subjects and class templates
    final colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#F7DC6F'];
    int colorIndex = 0;

    for (var entry in subjectGroups.entries) {
      final subjectName = entry.key;
      final drafts = entry.value;

      // Create subject
      final subject = Subject(
        id: const Uuid().v4(), //ignore: creation_with_non_type
        name: subjectName,
        color: colors[colorIndex % colors.length],
        credits: 3, // Default
        weights: [
          Weight(
            id: const Uuid().v4(), //ignore: creation_with_non_type
            name: 'Assignments',
            percentage: 100,
            subweights: [],
          ),
        ],
        useFinalGradeOverride: false,
        finalGrade: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveSubject(subject, userId, activeTerm.id);
      colorIndex++;

      // Create class templates for each draft
      for (var draft in drafts) {
        final startMinutes = _parseTimeToMinutes(draft.startText)!;
        final endMinutes = _parseTimeToMinutes(draft.endText)!;

        // Parse location into building and room
        String? building;
        String? room;
        final loc = draft.location.trim();
        if (loc.isNotEmpty) {
          final parts = loc.split('-');
          if (parts.length >= 2) {
            building = parts[0].trim();
            room = parts.skip(1).join('-').trim();
          } else {
            building = loc;
          }
        }

        // Create class template with weekly recurrence
        final classTemplate = ClassTemplate(
          id: const Uuid().v4(), //ignore: creation_with_non_type
          name: draft.title,
          icon: 'chalkboard', // Default icon
          startDate: activeTerm.startDate,
          endDate: activeTerm.endDate,
          startTime: draft.startText,
          endTime: draft.endText,
          recurrence: Recurrence(
            interval: 1,
            unit: RecurrenceUnit.weeks,
            selectedDays: draft.weekdays.toList()..sort(),
          ),
          building: building,
          room: room,
          teacherId: null, // Can be linked later
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          subjectId: subject.id,
        );

        await repo.saveClassTemplate(classTemplate, userId, activeTerm.id, subject.id);
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully imported ${subjectGroups.length} subject(s)!'),
      ),
    );

    Navigator.of(context).pop(true);
  }
}
