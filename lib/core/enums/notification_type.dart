import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Categories of automated and in-app football group notifications.
enum NotificationType {
  matchAnnouncement,
  waitingListPromoted,
  lineupPublished,
  motmPollStarted,
  matchResultPublished;

  String get labelArabic => switch (this) {
    NotificationType.matchAnnouncement => 'إعلان مباراة جديدة',
    NotificationType.waitingListPromoted => 'ترقية من قائمة الانتظار',
    NotificationType.lineupPublished => 'اعتماد تشكيلة الفرق',
    NotificationType.motmPollStarted => 'تصويت رجل المباراة ',
    NotificationType.matchResultPublished => 'نتيجة المباراة الرسمية ',
  };

  IconData get icon => switch (this) {
    NotificationType.matchAnnouncement => Icons.sports_soccer_rounded,
    NotificationType.waitingListPromoted => Icons.upgrade_rounded,
    NotificationType.lineupPublished => Icons.groups_rounded,
    NotificationType.motmPollStarted => Icons.military_tech_rounded,
    NotificationType.matchResultPublished => Icons.emoji_events_rounded,
  };

  Color get iconColor => switch (this) {
    NotificationType.matchAnnouncement => AppColors.turfGreen,
    NotificationType.waitingListPromoted => AppColors.amberText,
    NotificationType.lineupPublished => Colors.blueAccent,
    NotificationType.motmPollStarted => AppColors.amberText,
    NotificationType.matchResultPublished => AppColors.turfGreen,
  };
}
