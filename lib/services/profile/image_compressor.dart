// lib/services/profile/image_compressor.dart
import 'dart:isolate';
import 'dart:io';
import 'package:image/image.dart' as img;

/// Ejecuta la compresión/redimensionamiento de la imagen en un isolate,
/// para no colgar el hilo principal/UI.
class ImageCompressor {
  static Future<String> compressAndSave({
    required String inputPath,
    required String outputPath,
  }) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(_compressIsolateEntry, [
      receivePort.sendPort,
      inputPath,
      outputPath,
    ]);

    final result = await receivePort.first;
    if (result is String) return result;
    return '';
  }

  static Future<void> _compressIsolateEntry(List<dynamic> args) async {
    final SendPort sendPort = args[0];
    final String inPath = args[1];
    final String outPath = args[2];

    try {
      final originalBytes = await File(inPath).readAsBytes();
      final decoded = img.decodeImage(originalBytes);
      if (decoded == null) {
        sendPort.send('');
        return;
      }

      // Reducimos el avatar a ~256px de ancho para cache local eficiente
      final resized = img.copyResize(decoded, width: 256);

      // JPG 80% calidad = bueno y liviano
      final jpgBytes = img.encodeJpg(resized, quality: 80);

      final outFile = File(outPath);
      await outFile.writeAsBytes(jpgBytes, flush: true);

      sendPort.send(outPath);
    } catch (_) {
      sendPort.send('');
    }
  }
}
