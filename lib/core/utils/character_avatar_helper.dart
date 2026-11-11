import 'dart:math';
import 'package:flutter/material.dart';

/// Helper utility for generating and rendering athletic Character Avatars ("صور كاركترز").
///
/// Features:
/// 1. High-resolution DiceBear Adventurer character illustrations for online rendering.
/// 2. Standalone offline vector Character Painter (`CharacterAvatarPainter`) that draws
///    detailed, stylish football player cartoon characters directly on canvas without
///    requiring any network connection.
class CharacterAvatarHelper {
  CharacterAvatarHelper._();

  static const List<String> bgPalette = [
    'b6e3f4', // sky blue
    'c0aede', // lavender
    'd1d4f9', // soft indigo
    'ffd5dc', // rose
    'ffdfbf', // peach
    'dcfce7', // mint green
    'fef08a', // warm yellow
  ];

  /// Generates a deterministic, high-resolution illustrated character URL based on seed/name.
  static String getCharacterUrl(String name, {String? style}) {
    final cleanName = name.trim().replaceAll(RegExp(r'\s+'), '_');
    final effectiveStyle = style ?? 'adventurer';
    final bg = bgPalette[cleanName.hashCode.abs() % bgPalette.length];
    return 'https://api.dicebear.com/7.x/$effectiveStyle/png?seed=${Uri.encodeComponent(cleanName)}&backgroundColor=$bg';
  }

  /// Curated character presets for player registration and profile customization.
  static const List<Map<String, String>> characterPresets = [
    {
      'id': 'char_striker',
      'label': 'الهداف ⚽',
      'url': 'https://api.dicebear.com/7.x/adventurer/png?seed=StrikerAce&backgroundColor=b6e3f4',
    },
    {
      'id': 'char_captain',
      'label': 'الكابتن 👑',
      'url': 'https://api.dicebear.com/7.x/adventurer/png?seed=CaptainLeader&backgroundColor=ffd5dc',
    },
    {
      'id': 'char_goalkeeper',
      'label': 'الأخطبوط 🧤',
      'url': 'https://api.dicebear.com/7.x/adventurer/png?seed=GoalKeeperPro&backgroundColor=c0aede',
    },
    {
      'id': 'char_defender',
      'label': 'الصخرة 🧱',
      'url': 'https://api.dicebear.com/7.x/adventurer/png?seed=RockDefender&backgroundColor=dcfce7',
    },
    {
      'id': 'char_playmaker',
      'label': 'المايسترو 🪄',
      'url': 'https://api.dicebear.com/7.x/adventurer/png?seed=PlaymakerWizard&backgroundColor=d1d4f9',
    },
    {
      'id': 'char_winger',
      'label': 'السهم ⚡',
      'url': 'https://api.dicebear.com/7.x/adventurer/png?seed=SpeedWinger&backgroundColor=ffdfbf',
    },
  ];
}

/// Canvas CustomPainter that renders a rich, colorful cartoon/character football player face.
/// Works 100% offline with zero network dependency.
class CharacterAvatarPainter extends CustomPainter {
  final String seed;
  final bool isDark;

  CharacterAvatarPainter({required this.seed, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final int hash = seed.hashCode.abs();
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = min(w, h) / 2;

    // 1. Background Circle
    final List<Color> bgColors = [
      const Color(0xFFBAE6FD), // Sky
      const Color(0xFFDDD6FE), // Purple
      const Color(0xFFBBF7D0), // Mint
      const Color(0xFFFED7AA), // Peach
      const Color(0xFFFECDD3), // Rose
      const Color(0xFFFEF08A), // Yellow
      const Color(0xFFC7D2FE), // Indigo
    ];
    final bgColor = bgColors[hash % bgColors.length];
    final bgPaint = Paint()..color = bgColor;
    canvas.drawCircle(center, radius, bgPaint);

    // Clip to circle so shoulders and hair stay inside
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    // 2. Athletic Jersey Shoulders
    final List<Color> jerseyColors = [
      const Color(0xFF16A34A), // Emerald
      const Color(0xFF2563EB), // Royal Blue
      const Color(0xFFDC2626), // Crimson
      const Color(0xFFD97706), // Amber
      const Color(0xFF9333EA), // Purple
      const Color(0xFF0D9488), // Teal
      const Color(0xFF1E293B), // Navy Slate
    ];
    final jerseyColor = jerseyColors[(hash ~/ 7) % jerseyColors.length];
    final jerseyPaint = Paint()..color = jerseyColor;

    final shoulderPath = Path();
    shoulderPath.moveTo(w * 0.15, h);
    shoulderPath.quadraticBezierTo(w * 0.25, h * 0.72, w * 0.5, h * 0.72);
    shoulderPath.quadraticBezierTo(w * 0.75, h * 0.72, w * 0.85, h);
    shoulderPath.close();
    canvas.drawPath(shoulderPath, jerseyPaint);

    // Jersey V-neck / collar
    final collarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    final collarPath = Path();
    collarPath.moveTo(w * 0.40, h * 0.72);
    collarPath.lineTo(w * 0.50, h * 0.82);
    collarPath.lineTo(w * 0.60, h * 0.72);
    canvas.drawPath(collarPath, collarPaint);

    // 3. Neck
    final List<Color> skinTones = [
      const Color(0xFFFFDFC4), // Light Peach
      const Color(0xFFF0C8A0), // Warm Beige
      const Color(0xFFE0AC69), // Tan Golden
      const Color(0xFFC68642), // Honey Bronze
      const Color(0xFF8D5524), // Rich Espresso
    ];
    final skinTone = skinTones[(hash ~/ 13) % skinTones.length];
    final neckPaint = Paint()..color = Color.lerp(skinTone, Colors.black, 0.08)!;
    final neckRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.65),
      width: w * 0.22,
      height: h * 0.22,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, Radius.circular(w * 0.08)), neckPaint);

    // 4. Head / Face
    final facePaint = Paint()..color = skinTone;
    final headRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.44),
      width: w * 0.48,
      height: h * 0.52,
    );
    canvas.drawOval(headRect, facePaint);

    // Ears
    final earPaint = Paint()..color = skinTone;
    canvas.drawCircle(Offset(w * 0.24, h * 0.44), w * 0.065, earPaint);
    canvas.drawCircle(Offset(w * 0.76, h * 0.44), w * 0.065, earPaint);

    // 5. Hair & Headband
    final List<Color> hairColors = [
      const Color(0xFF1C1917), // Jet Black
      const Color(0xFF3E2723), // Dark Brown
      const Color(0xFF5D4037), // Chestnut
      const Color(0xFF2E1065), // Deep Midnight
      const Color(0xFF78350F), // Auburn
    ];
    final hairColor = hairColors[(hash ~/ 19) % hairColors.length];
    final hairPaint = Paint()..color = hairColor;

    final hairStyle = (hash ~/ 23) % 3;
    if (hairStyle == 0) {
      // Modern Athletic Fade
      final hairPath = Path();
      hairPath.moveTo(w * 0.22, h * 0.38);
      hairPath.quadraticBezierTo(w * 0.25, h * 0.16, w * 0.5, h * 0.16);
      hairPath.quadraticBezierTo(w * 0.75, h * 0.16, w * 0.78, h * 0.38);
      hairPath.quadraticBezierTo(w * 0.65, h * 0.28, w * 0.5, h * 0.28);
      hairPath.quadraticBezierTo(w * 0.35, h * 0.28, w * 0.22, h * 0.38);
      hairPath.close();
      canvas.drawPath(hairPath, hairPaint);
    } else if (hairStyle == 1) {
      // Curly / Voluminous
      final hairPath = Path();
      hairPath.addOval(Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.25),
        width: w * 0.54,
        height: h * 0.30,
      ));
      canvas.drawPath(hairPath, hairPaint);
    } else {
      // Spiky / Athletic Headband
      final hairPath = Path();
      hairPath.moveTo(w * 0.23, h * 0.35);
      hairPath.lineTo(w * 0.30, h * 0.18);
      hairPath.lineTo(w * 0.40, h * 0.22);
      hairPath.lineTo(w * 0.50, h * 0.15);
      hairPath.lineTo(w * 0.60, h * 0.22);
      hairPath.lineTo(w * 0.70, h * 0.18);
      hairPath.lineTo(w * 0.77, h * 0.35);
      hairPath.quadraticBezierTo(w * 0.5, h * 0.27, w * 0.23, h * 0.35);
      hairPath.close();
      canvas.drawPath(hairPath, hairPaint);
    }

    // 6. Facial Features
    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    final eyeRadius = w * 0.038;
    canvas.drawCircle(Offset(w * 0.40, h * 0.43), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(w * 0.60, h * 0.43), eyeRadius, eyePaint);

    // Eye catch-light (white twinkle)
    final twinklePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.41, h * 0.42), eyeRadius * 0.35, twinklePaint);
    canvas.drawCircle(Offset(w * 0.61, h * 0.42), eyeRadius * 0.35, twinklePaint);

    // Eyebrows
    final browPaint = Paint()
      ..color = hairColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.34, h * 0.37), Offset(w * 0.45, h * 0.38), browPaint);
    canvas.drawLine(Offset(w * 0.55, h * 0.38), Offset(w * 0.66, h * 0.37), browPaint);

    // Friendly smile
    final smilePaint = Paint()
      ..color = const Color(0xFF831843).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round;
    final smilePath = Path();
    smilePath.moveTo(w * 0.42, h * 0.54);
    smilePath.quadraticBezierTo(w * 0.50, h * 0.60, w * 0.58, h * 0.54);
    canvas.drawPath(smilePath, smilePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CharacterAvatarPainter oldDelegate) {
    return oldDelegate.seed != seed || oldDelegate.isDark != isDark;
  }
}

