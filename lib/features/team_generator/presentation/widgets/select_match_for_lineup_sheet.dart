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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  final cs = Theme.of(context).colorScheme;
                  final emerald = isDark
                      ? AppColors.turfGreenNeon
                      : AppColors.primaryEmerald;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.7),
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelectMatch(match);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Tactical Indigo Squircle Well
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.indigoAccent.withValues(
                                    alpha: isDark ? 0.16 : 0.10,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.sports_soccer_rounded,
                                  color: AppColors.indigoAccent,
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
                                          color: cs.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            match.pitchName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: cs.onSurfaceVariant,
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
                                          color: cs.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          match.formattedDateTime,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: cs.onSurfaceVariant,
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
                                      ? emerald.withValues(
                                          alpha: isDark ? 0.16 : 0.10,
                                        )
                                      : cs.surfaceContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$confirmedCount / $maxCount لاعب',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isFull
                                        ? emerald
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Arrow Chevron pointing left in RTL
                              Icon(
                                Icons.chevron_left_rounded,
                                size: 20,
                                color: cs.onSurfaceVariant,
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

