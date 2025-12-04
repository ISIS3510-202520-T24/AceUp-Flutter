import 'package:flutter/material.dart';

/// Application-wide constants for colors, avatars, and other reusable values
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // ==================== SUBJECT/GROUP COLOR PALETTE ====================

  static const List<Color> predefinedColors = [
    Color(0xFFF48FB1), // Light Pink
    Color(0xFFF06292), // Pink
    Color(0xFFE57373), // Red
    Color(0xFFEF5350), // Bright Red
    Color(0xFFFF7043), // Medium Deep Orange
    Color(0xFFFF8A65), // Deep Orange
    Color(0xFFFFA726), // Medium Orange
    Color(0xFFFFB74D), // Orange
    Color(0xFFFFD54F), // Amber
    Color(0xFFFFF176), // Yellow
    Color(0xFFDCE775), // Lime
    Color(0xFFAED581), // Light Green
    Color(0xFFA5D6A7), // Pale Green
    Color(0xFF81C784), // Green
    Color(0xFF4DB6AC), // Teal
    Color(0xFF80CBC4), // Light Teal
    Color(0xFF4DD0E1), // Cyan
    Color(0xFF4FC3F7), // Light Blue
    Color(0xFF64B5F6), // Blue
    Color(0xFF7986CB), // Indigo
    Color(0xFF9575CD), // Deep Purple
    Color(0xFFBA68C8), // Purple
    Color(0xFFCE93D8), // Light Purple
    Color(0xFFA1887F), // Brown
    Color(0xFF90A4AE), // Blue Gray
    Color(0xFFB0BEC5), // Medium Blue Gray
  ];

  /// Get color as hex string (e.g., "#FF6B6B")
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Parse hex string to Color (e.g., "#FF6B6B" -> Color(0xFFFF6B6B))
  static Color hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  /// Get a color from the palette by index
  static Color getSubjectColor(int index) {
    return predefinedColors[index % predefinedColors.length];
  }

  /// Find the index of a color in the palette (returns -1 if not found)
  static int getColorIndex(String hexColor) {
    final color = hexToColor(hexColor);
    return predefinedColors.indexWhere((c) => c.value == color.value);
  }

  // ==================== AVATAR/PROFILE CONSTANTS ====================

  /// Default avatar colors for user profiles (when no image is set)
  static const List<Color> avatarColors = [
    Color(0xFFE57373), // Light Red
    Color(0xFFFFB74D), // Light Orange
    Color(0xFFFFD54F), // Light Yellow
    Color(0xFF81C784), // Light Green
    Color(0xFF64B5F6), // Light Blue
    Color(0xFF9575CD), // Light Purple
    Color(0xFFFF8A80), // Light Pink
    Color(0xFFA1887F), // Light Brown
    Color(0xFF90A4AE), // Blue Gray
  ];

  /// Get avatar color based on user ID or name hash
  static Color getAvatarColor(String userId) {
    final hash = userId.hashCode.abs();
    return avatarColors[hash % avatarColors.length];
  }

  /// Get initials from a name (max 2 characters)
  static String getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  // ==================== DEFAULT AVATAR ASSET PATHS ====================

  /// Path to default user avatar image (if using an asset)
  static const String defaultAvatarPath = 'assets/avatars/goat_avatar.png';

  static const List<String> appAvatarPaths = [
    'assets/avatars/cat_avatar.png',
    'assets/avatars/bat_avatar.png',
    'assets/avatars/bear_avatar.png',
    'assets/avatars/beaver_avatar.png',
    'assets/avatars/boar_avatar.png',
    'assets/avatars/buffalo_avatar.png',
    'assets/avatars/camel_avatar.png',
    'assets/avatars/chameleon_avatar.png',
    'assets/avatars/cheetah_avatar.png',
    'assets/avatars/cow_avatar.png',
    'assets/avatars/deer_avatar.png',
    'assets/avatars/dog_avatar.png',
    'assets/avatars/duck_avatar.png',
    'assets/avatars/eagle_avatar.png',
    'assets/avatars/elephant_avatar.png',
    'assets/avatars/fox_avatar.png',
    'assets/avatars/frog_avatar.png',
    'assets/avatars/giraffe_avatar.png',
    'assets/avatars/goat_avatar.png',
    'assets/avatars/gorilla_avatar.png',
    'assets/avatars/hamster_avatar.png',
    'assets/avatars/hen_avatar.png',
    'assets/avatars/hippo_avatar.png',
    'assets/avatars/horse_avatar.png',
    'assets/avatars/kangaroo_avatar.png',
    'assets/avatars/koala_avatar.png',
    'assets/avatars/lemur_avatar.png',
    'assets/avatars/lion_avatar.png',
    'assets/avatars/llama_avatar.png',
    'assets/avatars/monkey_avatar.png',
    'assets/avatars/ostrich_avatar.png',
    'assets/avatars/owl_avatar.png',
    'assets/avatars/panda_avatar.png',
    'assets/avatars/penguin_avatar.png',
    'assets/avatars/pig_avatar.png',
    'assets/avatars/polarbear_avatar.png',
    'assets/avatars/rabbit_avatar.png',
    'assets/avatars/raccoon_avatar.png',
    'assets/avatars/rhinoceros_avatar.png',
    'assets/avatars/shark_avatar.png',
    'assets/avatars/sheep_avatar.png',
    'assets/avatars/sloth_avatar.png',
    'assets/avatars/snake_avatar.png',
    'assets/avatars/squirrel_avatar.png',
    'assets/avatars/swan_avatar.png',
    'assets/avatars/tiger_avatar.png',
    'assets/avatars/turtle_avatar.png',
    'assets/avatars/walrus_avatar.png',
    'assets/avatars/wolf_avatar.png',
    'assets/avatars/zebra_avatar.png',
  ];

  // ==================== OTHER CONSTANTS ====================

  /// Default class duration in minutes
  static const int defaultClassDuration = 60;

  /// Default weekdays (Monday to Friday)
  static const List<int> defaultWeekdays = [1, 2, 3, 4, 5];

  /// Maximum file upload size (in bytes) - 5MB
  static const int maxFileUploadSize = 5 * 1024 * 1024;

  /// Supported image formats for avatars and group images
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  /// Default country code for holidays
  static const String defaultCountryCode = 'CO'; // Colombia

  /// Time format for display
  static const String timeFormat = 'HH:mm';

  /// Date format for display
  static const String dateFormat = 'MMM d, yyyy';
}
