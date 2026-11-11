import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_bottom_sheet_shell.dart';
import '../../../matches/domain/entities/match_entity.dart';

/// Modal bottom sheet allowing the Captain to select which match/booking
/// to generate or manage tactical team lineups for.
class SelectMatchForLineupSheet extends StatelessWidget {
  final List<MatchEntity> matches;
  final ValueChanged<MatchEntity> onSelectMatch;

  const SelectMatchForLineupSheet({
    super.key,
    required this.matches,
    required this.onSelectMatch,
  });

  static Future<void> show(
    BuildContext context, {
    required List<MatchEntity> matches,
    required ValueChanged<MatchEntity> onSelectMatch,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SelectMatchForLineupSheet(
        matches: matches,
        onSelectMatch: onSelectMatch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffBottomSheetShell(
      title: 'اختر المباراة لتوزيع الفرق ⚽',
      subtitle: 'حدد الحجز المطلوب للبدء في توليد التشكيلة التكتيكية المتوازنة',
      icon: Icons.balance_rounded,
      heightFactor: 0.65,
      child: matches.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 48,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد حجوزات أو مباريات نشطة حالياً',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'قم بإنشاء مباراة جديدة أولاً لتتمكن من توزيع الفرق.',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...matches.map((match) {
                  final confirmedCount = match.confirmedPlayers.length;
                  final maxCount = match.maxPlayers;
                  final isFull = confirmedCount >= maxCount;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A3A30)
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelectMatch(match);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Soccer Icon Container
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDarkElevated
                                      : AppColors.meadowTint,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.sports_soccer_rounded,
                                  color: AppColors.turfGreenDark,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Match Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      match.title,
                                      style: context.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.stadium_rounded,
                                          size: 14,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : const Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            match.pitchName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? AppColors.textSecondaryDark
                                                  : const Color(0xFF64748B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 14,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : const Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          match.formattedDateTime,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Attendance Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isFull
                                      ? (isDark
                                          ? const Color(0xFF1E3A2B)
                                          : const Color(0xFFDCFCE7))
                                      : (isDark
                                          ? const Color(0xFF262626)
                                          : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$confirmedCount / $maxCount لاعب',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isFull
                                        ? (isDark
                                            ? AppColors.turfGreenNeon
                                            : AppColors.turfGreenDark)
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : const Color(0xFF475569)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Arrow Chevron
                              Icon(
                                context.isRtl
                                    ? Icons.chevron_right_rounded
                                    : Icons.chevron_right_rounded,
                                size: 20,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

