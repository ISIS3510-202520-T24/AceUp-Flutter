import 'dart:io';
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
  /// The image is compressed to 512x512 pixels with 85% quality to save bandwidth.
  /// Returns the download URL if successful, null otherwise.
  /// 
  /// Path format: group_images/{groupId}.jpg
  Future<String?> uploadGroupImage(File imageFile, String groupId) async {
    try {
      // Read and decode image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      // Resize to 512x512 maintaining aspect ratio
      img.Image resized;
      if (image.width > image.height) {
        resized = img.copyResize(image, width: _maxImageSize);
      } else {
        resized = img.copyResize(image, height: _maxImageSize);
      }

      // Encode as JPEG with compression
      final compressed = img.encodeJpg(resized, quality: _jpegQuality);

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
