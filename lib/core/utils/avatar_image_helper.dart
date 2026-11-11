import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Helper utility for selecting, compressing, and encoding player avatars as
/// lightweight Base64 strings that fit directly into Firestore documents without
/// requiring a paid Firebase Storage (Blaze plan) subscription.
class AvatarImageHelper {
  AvatarImageHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from [source] (gallery or camera), scales it down to maximum
  /// [maxWidth] x [maxHeight] and [imageQuality] (JPEG 75%), then returns a Base64
  /// data URI (`data:image/jpeg;base64,...`).
  ///
  /// Typical size: 12KB to 28KB, well below the Firestore 1MB per-doc limit.
  static Future<String?> pickAndEncodeImage({
    ImageSource source = ImageSource.gallery,
    int maxWidth = 256,
    int maxHeight = 256,
    int imageQuality = 75,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (file == null) return null;

      final Uint8List bytes = await file.readAsBytes();
      final String base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Error picking or encoding image to Base64: $e');
      return null;
    }
  }

  /// Safely extracts and decodes bytes from a Base64 string or data URI.
  /// Returns `null` if the string is invalid or not Base64.
  static Uint8List? tryDecodeBase64(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    try {
      if (trimmed.startsWith('data:image')) {
        final commaIndex = trimmed.indexOf(',');
        if (commaIndex != -1) {
          final base64Part = trimmed.substring(commaIndex + 1).trim();
          return base64Decode(base64Part);
        }
      }

      // Check if it's raw base64 without data URI scheme
      // (Long string, no protocol, no spaces)
      if (trimmed.length > 60 &&
          !trimmed.startsWith('http://') &&
          !trimmed.startsWith('https://') &&
          !trimmed.contains(' ') &&
          !trimmed.contains('\n')) {
        return base64Decode(trimmed);
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}

