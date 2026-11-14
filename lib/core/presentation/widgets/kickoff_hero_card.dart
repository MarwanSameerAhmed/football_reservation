import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../extensions/context_extensions.dart';
import '../../motion/kickoff_motion.dart';

/// Clean `tam_app`-styled Matchday Hero Card.
///
/// Features:
/// - Clean white (`#FFFFFF`) card surface in Light Mode and dark slate (`#1D222C`) in Dark Mode.
/// - Crisp `1px` hairline `outlineVariant` border with zero heavy shadows.
/// - Tonal inner summary sub-panel for stadium, date, time, and attendance.
/// - Tabular figures (`FontFeature.tabularFigures`) for aligned player counts.
/// - Single 1-tap RSVP CTA matching `tam_app` button hierarchy.
class KickoffHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? matchTitle;
  final String? matchDate;
  final String? matchTime;
  final int confirmedPlayers;
  final int maxPlayers;
  final int waitingCount;
  final String? rating;
  final String? fee;
  final String? distanceOrDate;
  final String? imageUrl;
  final bool isUserRegistered;
  final bool isRegistrationOpen;
  final DateTime? registrationOpensAt;
  final VoidCallback? onTap;
  final VoidCallback? onRsvpTap;

  const KickoffHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.matchTitle,
    this.matchDate,
    this.matchTime,
    this.confirmedPlayers = 14,
    this.maxPlayers = 18,
    this.waitingCount = 0,
    this.rating,
    this.fee,
    this.distanceOrDate,
    this.imageUrl,
    this.isUserRegistered = false,
    this.isRegistrationOpen = true,
    this.registrationOpensAt,
    this.onTap,
    this.onRsvpTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final displayMatchTitle = matchTitle ?? 'مباراة الجمعة الكبرى';
    final displayDate = matchDate ?? 'الجمعة 14 نوفمبر';
    final displayTime = matchTime ?? '08:30 م';
    final totalSeats = maxPlayers > 0 ? maxPlayers : 18;
    final remaining = (totalSeats - confirmedPlayers).clamp(0, totalSeats);
    final isFull = confirmedPlayers >= totalSeats;
    final double fillPercentage = (confirmedPlayers / totalSeats).clamp(
      0.0,
      1.0,
    );

    final statusColor = !isRegistrationOpen
        ? cs.primary
        : isFull
        ? AppColors.rose
        : AppColors.emerald;

    return Semantics(
      button: onTap != null,
      label: '$displayMatchTitle, $title, $subtitle',
      child: KickoffPressable(
        enabled: onTap != null,
        child: Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUserRegistered
                      ? cs.primary
                      : (isDark
                            ? cs.primary.withValues(alpha: 0.38)
                            : cs.primary.withValues(alpha: 0.25)),
                  width: isUserRegistered ? 1.5 : 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Pill Row
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      // Matchday Header Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.22),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sports_soccer_rounded,
                              size: 13,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'المباراة القادمة',
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Availability Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(
                            alpha: isDark ? 0.16 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              !isRegistrationOpen && registrationOpensAt != null
                                  ? 'يفتح الحجز ${DateFormat('hh:mm a', 'ar').format(registrationOpensAt!)}'
                                  : isFull
                                  ? 'قائمة انتظار'
                                  : (remaining <= 3
                                        ? 'متبقي $remaining مقاعد فقط'
                                        : 'التسجيل متاح'),
                              style: TextStyle(
                                color: !isRegistrationOpen
                                    ? cs.primary
                                    : isFull
                                    ? (isDark
                                          ? AppColors.darkRose
                                          : AppColors.rose)
                                    : (isDark
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF087F5B)),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bold Match Title
                  Text(
                    displayMatchTitle,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Clean Tonal Info & Progress Sub-Panel
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outlineVariant, width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.stadium_rounded,
                              size: 16,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$title • $subtitle',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$displayDate • الساعة $displayTime',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Attendance Row with Tabular Figures
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'الحضور: $confirmedPlayers من $totalSeats لاعب',
                                style: AppTypography.tabular(
                                  TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              waitingCount > 0
                                  ? '$waitingCount في الانتظار'
                                  : (remaining == 0
                                        ? 'اكتمل العدد'
                                        : 'متبقي $remaining ${remaining > 10 ? "مقعداً" : "مقاعد"}'),
                              style: AppTypography.tabular(
                                TextStyle(
                                  color: cs.primary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: fillPercentage,
                            minHeight: 7,
                            backgroundColor: cs.outlineVariant.withValues(
                              alpha: 0.7,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 1-Tap RSVP Action Button (tam_app FilledButton Ink hierarchy)
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isUserRegistered
                          ? AppColors.emerald.withValues(
                              alpha: isDark ? 0.16 : 0.10,
                            )
                          : (!isRegistrationOpen
                                ? cs.surfaceContainer
                                : (isDark
                                      ? AppColors.darkText
                                      : AppColors.ink)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUserRegistered
                            ? AppColors.emerald.withValues(alpha: 0.45)
                            : (!isRegistrationOpen
                                  ? cs.outlineVariant
                                  : Colors.transparent),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: !isRegistrationOpen
                            ? null
                            : (onRsvpTap ?? onTap),
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isUserRegistered
                                        ? Icons.check_circle_rounded
                                        : (!isRegistrationOpen
                                              ? Icons.timer_outlined
                                              : Icons.sports_soccer_rounded),
                                    size: 19,
                                    color: isUserRegistered
                                        ? (isDark
                                              ? const Color(0xFF34D399)
                                              : const Color(0xFF087F5B))
                                        : (!isRegistrationOpen
                                              ? cs.onSurfaceVariant
                                              : (isDark
                                                    ? AppColors.ink
                                                    : Colors.white)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isUserRegistered
                                        ? 'أنت مسجل أساسي ✓ (اضغط للإلغاء)'
                                        : (!isRegistrationOpen &&
                                                  registrationOpensAt != null
                                              ? 'يبدأ الحجز الساعة ${DateFormat('hh:mm a', 'ar').format(registrationOpensAt!)}'
                                              : (isFull
                                                    ? 'الانضمام لقائمة الانتظار'
                                                    : 'تأكيد حضوري للمباراة')),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isUserRegistered
                                          ? (isDark
                                                ? const Color(0xFF34D399)
                                                : const Color(0xFF087F5B))
                                          : (!isRegistrationOpen
                                                ? cs.onSurfaceVariant
                                                : (isDark
                                                      ? AppColors.ink
                                                      : Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
