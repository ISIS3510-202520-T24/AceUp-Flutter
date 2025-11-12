import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Service for uploading and managing group images in Firebase Storage.
/// 
/// Unlike profile avatars which are stored locally, group images are stored
/// in Firebase Storage so all group members can see the same image across devices.
class GroupImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const int _maxImageSize = 512; // pixels
  static const int _jpegQuality = 85; // compression quality

  /// Uploads a group image to Firebase Storage.
  /// 
  /// 🔹 ISOLATE: Uses compute() to compress image in separate isolate, preventing UI freeze.
  /// The image is compressed to 512x512 pixels with 85% quality to save bandwidth.
  /// Returns the download URL if successful, null otherwise.
  /// 
  /// Path format: group_images/{groupId}.jpg
  Future<String?> uploadGroupImage(File imageFile, String groupId) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // 🔹 ISOLATE: Comprimir imagen en isolate separado usando compute()
      // compute() ejecuta _compressImageInIsolate en un thread de background
      debugPrint('🔄 Comprimiendo imagen en isolate...');
      final compressed = await compute(_compressImageInIsolate, bytes);
      
      if (compressed == null) {
        debugPrint('❌ Failed to compress image in isolate');
        return null;
      }
      
      debugPrint('✅ Imagen comprimida en isolate (${compressed.length} bytes)');

      // Upload to Firebase Storage
      final ref = _storage.ref().child('group_images/$groupId.jpg');
      
      final uploadTask = ref.putData(
        Uint8List.fromList(compressed),
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Group image uploaded: $downloadUrl');
      return downloadUrl;

    } catch (e) {
      debugPrint('Error uploading group image: $e');
      return null;
    }
  }

  /// Deletes a group image from Firebase Storage.
  /// Returns true if successful, false otherwise.
  Future<bool> deleteGroupImage(String groupId) async {
    try {
      final ref = _storage.ref().child('group_images/$groupId.jpg');
      await ref.delete();
      debugPrint('Group image deleted for groupId: $groupId');
      return true;
    } catch (e) {
      debugPrint('Error deleting group image: $e');
      return false;
    }
  }

  /// Gets the download URL for a group image.
  /// Returns null if the image doesn't exist.
  Future<String?> getGroupImageUrl(String groupId) async {
    try {
      final ref = _storage.ref().child('group_images/$groupId.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('ℹNo image found for groupId: $groupId');
      return null;
    }
  }
}

/// 🔹 ISOLATE: Función top-level que se ejecuta en un isolate separado
/// Esta función DEBE estar fuera de la clase para poder ser usada con compute()
/// 
/// Recibe bytes de imagen y retorna bytes comprimidos en JPEG
Uint8List? _compressImageInIsolate(Uint8List bytes) {
  try {
    // Decode image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return null;

    // Resize to 512x512 maintaining aspect ratio
    img.Image resized;
    if (image.width > image.height) {
      resized = img.copyResize(image, width: 512);
    } else {
      resized = img.copyResize(image, height: 512);
    }

    // Encode as JPEG with 85% quality
    final compressed = img.encodeJpg(resized, quality: 85);
    return Uint8List.fromList(compressed);
  } catch (e) {
    debugPrint('Error in isolate compression: $e');
    return null;
  }
}
