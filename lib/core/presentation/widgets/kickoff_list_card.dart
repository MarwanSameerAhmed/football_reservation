import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../extensions/context_extensions.dart';
import '../../motion/kickoff_motion.dart';
import 'kickoff_badge.dart';

/// Executive Squircle List Card with tinted icon well and crisp hairline border.
class KickoffListCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeLabel;
  final BadgeVariant badgeVariant;
  final String? extraInfo;
  final Widget? leading;
  final VoidCallback? onTap;

  const KickoffListCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.badgeVariant = BadgeVariant.success,
    this.extraInfo,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final tint = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;

    return Semantics(
      button: onTap != null,
      label: '$title, $subtitle',
      child: KickoffPressable(
        enabled: onTap != null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: cs.outlineVariant,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  // Leading squircle thumbnail or player avatar
                  leading ??
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: tint.withValues(alpha: isDark ? 0.16 : 0.11),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.sports_soccer_rounded,
                          color: tint,
                          size: 22,
                        ),
                      ),

                  const SizedBox(width: 12),

                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Trailing Badges and extra info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeLabel != null)
                        KickoffBadge(
                          label: badgeLabel!,
                          variant: badgeVariant,
                        ),
                      if (extraInfo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          extraInfo!,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
