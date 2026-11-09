import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';

class MatchStatusBadge extends StatelessWidget {
  final MatchStatus status;
  final int availableSpots;

  const MatchStatusBadge({
    super.key,
    required this.status,
    this.availableSpots = 0,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MatchStatus.upcoming:
        final label = availableSpots > 0
            ? 'متاح ($availableSpots مقاعد)'
            : status.labelArabic;
        return KickoffBadge(
          label: label,
          variant: BadgeVariant.success,
          leading: const Icon(
            Icons.check_circle_outline_rounded,
            size: 12,
            color: AppColors.turfGreenDark,
          ),
        );
      case MatchStatus.full:
        return KickoffBadge(
          label: status.labelArabic,
          variant: BadgeVariant.warning,
          leading: const Icon(
            Icons.hourglass_top_rounded,
            size: 12,
            color: AppColors.amberText,
          ),
        );
      case MatchStatus.inProgress:
        return KickoffBadge(
          label: status.labelArabic,
          variant: BadgeVariant.success,
          leading: const Icon(
            Icons.sports_soccer_rounded,
            size: 12,
            color: AppColors.turfGreenDark,
          ),
        );
      case MatchStatus.completed:
        return KickoffBadge(
          label: status.labelArabic,
          variant: BadgeVariant.neutral,
        );
      case MatchStatus.cancelled:
        return KickoffBadge(
          label: status.labelArabic,
          variant: BadgeVariant.danger,
          leading: const Icon(
            Icons.cancel_outlined,
            size: 12,
            color: AppColors.redText,
          ),
        );
    }
  }
}
