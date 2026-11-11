import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/enums/player_position.dart';
import '../../core/extensions/context_extensions.dart';
import '../../features/matches/domain/entities/match_entity.dart';
import '../../features/team_generator/domain/entities/team_lineup_entity.dart';

/// Helper to generate ultra-clean, beautifully formatted Arabic WhatsApp messages
/// for match lineups, and copy them directly to the clipboard with haptic feedback.
class LineupShareHelper {
  LineupShareHelper._();

  /// Builds a beautifully structured, emoji-adorned WhatsApp message for match lineups.
  static String formatWhatsAppLineup({
    required MatchEntity match,
    required TeamLineupEntity lineup,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('⚽ *تشكيلات ${match.title}* ⚽');
    buffer.writeln('📅 *الموعد:* ${match.formattedDateTime}');
    buffer.writeln('📍 *الملعب:* ${match.pitchName}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');

    final colorEmojis = ['🟢', '🔵', '🟠', '🔴', '🟡', '🟣'];

    for (int i = 0; i < lineup.teams.length; i++) {
      final team = lineup.teams[i];
      final emoji = colorEmojis[i % colorEmojis.length];
      buffer.writeln();
      buffer.writeln(
        '$emoji *${team.name}* (معدل القوة: ${team.averageRating.toStringAsFixed(1)})',
      );

      // Group players by position
      final gks = team.players
          .where((p) => p.primaryPosition == PlayerPosition.goalkeeper)
          .toList();
      final defs = team.players
          .where((p) => p.primaryPosition == PlayerPosition.defender)
          .toList();
      final mids = team.players
          .where((p) => p.primaryPosition == PlayerPosition.midfielder)
          .toList();
      final fwds = team.players
          .where((p) => p.primaryPosition == PlayerPosition.forward)
          .toList();

      if (gks.isNotEmpty) {
        final names = gks
            .map(
              (p) =>
                  '${p.name}${p.jerseyNumber != null ? ' #${p.jerseyNumber}' : ''}',
            )
            .join('، ');
        buffer.writeln('🧤 *حراسة المرمى:* $names');
      }
      if (defs.isNotEmpty) {
        final names = defs
            .map(
              (p) =>
                  '${p.name}${p.jerseyNumber != null ? ' #${p.jerseyNumber}' : ''}',
            )
            .join('، ');
        buffer.writeln('🛡️ *خط الدفاع:* $names');
      }
      if (mids.isNotEmpty) {
        final names = mids
            .map(
              (p) =>
                  '${p.name}${p == team.captain ? ' (C)' : ''}${p.jerseyNumber != null ? ' #${p.jerseyNumber}' : ''}',
            )
            .join('، ');
        buffer.writeln('⚙️ *خط الوسط:* $names');
      }
      if (fwds.isNotEmpty) {
        final names = fwds
            .map(
              (p) =>
                  '${p.name}${p.jerseyNumber != null ? ' #${p.jerseyNumber}' : ''}',
            )
            .join('، ');
        buffer.writeln('⚡ *خط الهجوم:* $names');
      }

      final others = team.players
          .where(
            (p) =>
                p.primaryPosition != PlayerPosition.goalkeeper &&
                p.primaryPosition != PlayerPosition.defender &&
                p.primaryPosition != PlayerPosition.midfielder &&
                p.primaryPosition != PlayerPosition.forward,
          )
          .toList();
      if (others.isNotEmpty) {
        final names = others.map((p) => p.name).join('، ');
        buffer.writeln('🏃 *اللاعبون:* $names');
      }

      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    }

    buffer.writeln();
    buffer.writeln('⚠️ *تنبيهات هامة للكابتن واللاعبين:*');
    buffer.writeln('• يرجى التواجد بالملعب قبل الانطلاق بـ 15 دقيقة للإحماء.');
    buffer.writeln('• الالتزام بألوان القمصان المحددة لكل فريق 👕.');
    buffer.writeln('• تمنياتنا للجميع بمباراة ممتعة وتنافس أخوي راقٍ! 🏆⚽');

    return buffer.toString();
  }

  /// Copies formatted lineup to clipboard and triggers a native-feeling toast notification.
  static void copyLineupToClipboard(
    BuildContext context, {
    required MatchEntity match,
    required TeamLineupEntity lineup,
  }) {
    final text = formatWhatsAppLineup(match: match, lineup: lineup);
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    context.showSuccessToast(
      'تم نسخ التشكيلات بنسق واتساب المنظم بنجاح! الصقها في قروب الواتساب 📲',
    );
  }
}

