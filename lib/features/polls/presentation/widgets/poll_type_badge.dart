import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/poll_type.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';

class PollTypeBadge extends StatelessWidget {
  final PollType type;

  const PollTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case PollType.matchScheduling:
        return const KickoffBadge(
          label: 'موعد ومكان',
          variant: BadgeVariant.success,
          leading: Icon(
            Icons.event_available_rounded,
            size: 13,
            color: AppColors.turfGreenDark,
          ),
        );
      case PollType.manOfTheMatch:
        return const KickoffBadge(
          label: 'رجل المباراة ⭐',
          variant: BadgeVariant.warning,
          leading: Icon(
            Icons.military_tech_rounded,
            size: 13,
            color: AppColors.amberText,
          ),
        );
      case PollType.general:
        return const KickoffBadge(
          label: 'استطلاع عام',
          variant: BadgeVariant.neutral,
          leading: Icon(
            Icons.poll_rounded,
            size: 13,
            color: AppColors.textSecondaryLight,
          ),
        );
    }
  }
}
