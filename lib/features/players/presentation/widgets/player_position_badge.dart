import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';

class PlayerPositionBadge extends StatelessWidget {
  final PlayerPosition position;
  final bool showFullLabel;

  const PlayerPositionBadge({
    super.key,
    required this.position,
    this.showFullLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = showFullLabel ? position.labelArabic : position.acronym;

    switch (position) {
      case PlayerPosition.goalkeeper:
        return KickoffBadge(
          label: label,
          variant: BadgeVariant.warning,
          leading: const Icon(
            Icons.pan_tool_rounded,
            size: 12,
            color: AppColors.amberText,
          ),
        );
      case PlayerPosition.defender:
        return KickoffBadge(
          label: label,
          variant: BadgeVariant.neutral,
          leading: const Icon(
            Icons.shield_outlined,
            size: 12,
            color: AppColors.textSecondaryLight,
          ),
        );
      case PlayerPosition.midfielder:
        return KickoffBadge(
          label: label,
          variant: BadgeVariant.success,
          leading: const Icon(
            Icons.hub_outlined,
            size: 12,
            color: AppColors.turfGreenDark,
          ),
        );
      case PlayerPosition.forward:
        return KickoffBadge(
          label: label,
          variant: BadgeVariant.danger,
          leading: const Icon(
            Icons.local_fire_department_rounded,
            size: 12,
            color: AppColors.redText,
          ),
        );
    }
  }
}
