import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../models/schedule_event.dart';
import 'manual_schedule_edit_screen.dart';

class AiImportScheduleScreen extends StatefulWidget {
  const AiImportScheduleScreen({super.key});

  @override
  State<AiImportScheduleScreen> createState() =>
      _AiImportScheduleScreenState();
}

class _AiImportScheduleScreenState extends State<AiImportScheduleScreen> {
  final ImagePicker _picker = ImagePicker();
  late final TextRecognizer _textRecognizer;

  bool _isProcessing = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage || _isProcessing) return; // evita doble toque
    _isPickingImage = true;

    try {
      final xFile = await _picker.pickImage(source: source);
      if (xFile == null) return;

      setState(() {
        _isProcessing = true;
      });

      final inputImage = InputImage.fromFilePath(xFile.path);
      final recognizedText =
          await _textRecognizer.processImage(inputImage);

      final parsedEvents = _parseScheduleText(recognizedText.text);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (parsedEvents.isEmpty) {
        // No encontró nada: mandamos al manual vacío pero avisamos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No schedule patterns detected. You can edit manually.',
            ),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ManualScheduleEditScreen(),
          ),
        );
      } else {
        // Sí encontró: vamos al manual con drafts
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ManualScheduleEditScreen(
              initialDrafts: parsedEvents,
            ),
          ),
        );
      }
    } finally {
      _isPickingImage = false;
    }
  }

  List<ScheduleEvent> _parseScheduleText(String text) {
    final lines = text.split('\n');
    final events = <ScheduleEvent>[];

    final RegExp timeRangeRegex =
        RegExp(r'(\d{1,2}:\d{2})\s*[-–]\s*(\d{1,2}:\d{2})');

    int? _weekdayFromLine(String lineUpper) {
      if (lineUpper.contains('LUNES') ||
          lineUpper.contains('MONDAY')) return DateTime.monday;
      if (lineUpper.contains('MARTES') ||
          lineUpper.contains('TUESDAY')) return DateTime.tuesday;
      if (lineUpper.contains('MIERCOLES') ||
          lineUpper.contains('MIÉRCOLES') ||
          lineUpper.contains('WEDNESDAY')) {
        return DateTime.wednesday;
      }
      if (lineUpper.contains('JUEVES') ||
          lineUpper.contains('THURSDAY')) return DateTime.thursday;
      if (lineUpper.contains('VIERNES') ||
          lineUpper.contains('FRIDAY')) return DateTime.friday;
      if (lineUpper.contains('SABADO') ||
          lineUpper.contains('SÁBADO') ||
          lineUpper.contains('SATURDAY')) return DateTime.saturday;
      if (lineUpper.contains('DOMINGO') ||
          lineUpper.contains('SUNDAY')) return DateTime.sunday;
      return null;
    }

    int _parseTimeToMinutes(String timeStr) {
      // acepta "8:00", "08:00", "8:00 a.m." etc.
      final cleaned = timeStr
          .toLowerCase()
          .replaceAll('am', '')
          .replaceAll('pm', '')
          .replaceAll('a.m.', '')
          .replaceAll('p.m.', '')
          .trim();
      final parts = cleaned.split(':');
      if (parts.length != 2) return 0;

      var hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return hour * 60 + minute;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    var counter = 0;

    int? currentWeekday;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final upper = line.toUpperCase();
      final detectedWeekday = _weekdayFromLine(upper);
      if (detectedWeekday != null) {
        currentWeekday = detectedWeekday;
      }

      final match = timeRangeRegex.firstMatch(line);
      if (match == null) continue;

      final startStr = match.group(1)!;
      final endStr = match.group(2)!;

      final startMinutes = _parseTimeToMinutes(startStr);
      final endMinutes = _parseTimeToMinutes(endStr);

      if (currentWeekday == null) {
        // Si no detectamos día, asumimos lunes por defecto.
        currentWeekday = DateTime.monday;
      }

      final title =
          line.replaceAll(match.group(0)!, '').trim().take(40);

      events.add(
        ScheduleEvent(
          id: '${now}_${counter++}',
          title: title.isEmpty ? 'Imported class' : title,
          weekday: currentWeekday!,
          startMinutes: startMinutes,
          endMinutes: max(startMinutes + 60, endMinutes),
          source: ScheduleSource.aiImport,
          kind: ScheduleKind.classEvent,
        ),
      );
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import schedule with AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Take a clear photo or choose an image of your timetable. '
              'We will detect days, times and subjects and send them as drafts '
              'to the manual editor.',
            ),
            const SizedBox(height: 24),
            if (_isProcessing) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 12),
              const Center(child: Text('Processing image...')),
              const SizedBox(height: 24),
            ],
            OutlinedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text('From gallery'),
              onPressed:
                  _isProcessing ? null : () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take photo'),
              onPressed:
                  _isProcessing ? null : () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String take(int maxLen) =>
      length <= maxLen ? this : substring(0, maxLen);
}
