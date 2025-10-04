import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Inter';

  /// AceUp Wordmark
  static const TextStyle logo = TextStyle(
    fontFamily: 'Sansita',
    fontSize: 32,
  );

  /// Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontVariations: [
      FontVariation('wght', 800), // Extra Bold
    ],
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontVariations: [
      FontVariation('wght', 800), // Extra Bold
    ],
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontVariations: [
      FontVariation('wght', 800), // Extra Bold
    ],
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontVariations: [
      FontVariation('wght', 700), // Bold
    ],
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontVariations: [
      FontVariation('wght', 700), // Bold
    ],
  );

  /// Body
  static const TextStyle bodyXL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontVariations: [
      FontVariation('wght', 400), // Regular
    ],
  );

  static const TextStyle bodyL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontVariations: [
      FontVariation('wght', 400), // Regular
    ],
  );

  static const TextStyle bodyM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontVariations: [
      FontVariation('wght', 400), // Regular
    ],
  );

  static const TextStyle bodyS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontVariations: [
      FontVariation('wght', 400), // Regular
    ],
  );

  static const TextStyle bodyXS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontVariations: [
      FontVariation('wght', 500), // Medium
    ],
  );

  /// Actions
  static const TextStyle actionL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontVariations: [
      FontVariation('wght', 600), // Semi Bold
    ],
  );

  static const TextStyle actionM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontVariations: [
      FontVariation('wght', 600), // Semi Bold
    ],
  );

  static const TextStyle actionS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontVariations: [
      FontVariation('wght', 600), // Semi Bold
    ],
  );

  /// Caption
  static const TextStyle captionM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontVariations: [
      FontVariation('wght', 600), // Semi Bold
    ],
  );
}
