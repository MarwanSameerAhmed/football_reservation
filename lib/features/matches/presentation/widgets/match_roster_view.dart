import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../players/presentation/widgets/player_position_badge.dart';
import '../../domain/entities/match_entity.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';

class MatchRosterView extends StatelessWidget {
  final MatchEntity match;
  final String? currentUserId;
  final bool isAdmin;
  final VoidCallback? onCancelMyRegistration;

  const MatchRosterView({
    super.key,
    required this.match,
    this.currentUserId,
    this.isAdmin = false,
    this.onCancelMyRegistration,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final accent = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;
    final warningColor = isDark ? AppColors.amberNeon : AppColors.amberText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Confirmed Squad Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التشكيلة الأساسية المؤكدة (${match.confirmedPlayers.length}/${match.maxPlayers})',
              style: context.textTheme.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            KickoffBadge(
              label: '${match.availableSpots} شاغر',
              variant: match.availableSpots > 0
                  ? BadgeVariant.success
                  : BadgeVariant.warning,
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (match.confirmedPlayers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: const Center(
              child: Text('لم يسجل أي لاعب في التشكيلة الأساسية بعد.'),
            ),
          )
        else
          ...List.generate(match.confirmedPlayers.length, (index) {
            final reg = match.confirmedPlayers[index];
            final isMe = reg.playerId == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMe ? accent : cs.outlineVariant,
                  width: isMe ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: cs.surfaceContainer,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            reg.playerName,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          const KickoffBadge(
                            label: 'أنت',
                            variant: BadgeVariant.success,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PlayerPositionBadge(position: reg.playerPosition),
                  if (isAdmin) ...[
                    // Demote to waiting list
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_downward_rounded,
                        size: 19,
                        color: Colors.orange,
                      ),
                      tooltip: 'إنزال لقائمة الانتظار',
                      onPressed: () {
                        context.read<MatchesBloc>().add(
                          DemotePlayerToWaitlistRequested(
                            matchId: match.id,
                            playerId: reg.playerId,
                          ),
                        );
                      },
                    ),
                    // Remove/Delete player from match
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                        color: AppColors.redText,
                      ),
                      tooltip: 'حذف اللاعب من الحجز',
                      onPressed: () {
                        context.read<MatchesBloc>().add(
                          CancelRegistrationRequested(
                            matchId: match.id,
                            playerId: reg.playerId,
                          ),
                        );
                      },
                    ),
                  ] else if (isMe && onCancelMyRegistration != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 18,
                        color: AppColors.redText,
                      ),
                      tooltip: 'إلغاء الحضور',
                      onPressed: onCancelMyRegistration,
                    ),
                  ],
                ],
              ),
            );
          }),

        const SizedBox(height: 24),

        // Waiting List Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'قائمة الانتظار (${match.waitingList.length})',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const KickoffBadge(
              label: 'تصعيد تلقائي',
              variant: BadgeVariant.neutral,
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (match.waitingList.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: const Center(child: Text('قائمة الانتظار فارغة حالياً.')),
          )
        else
          ...List.generate(match.waitingList.length, (index) {
            final reg = match.waitingList[index];
            final isMe = reg.playerId == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: warningColor.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: warningColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${reg.queuePosition ?? (index + 1)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: warningColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reg.playerName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PlayerPositionBadge(position: reg.playerPosition),
                  if (isAdmin) ...[
                    // Promote to confirmed squad
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 19,
                        color: AppColors.turfGreen,
                      ),
                      tooltip: 'ترقية للتشكيلة الأساسية',
                      onPressed: () {
                        context.read<MatchesBloc>().add(
                          PromotePlayerToConfirmedRequested(
                            matchId: match.id,
                            playerId: reg.playerId,
                          ),
                        );
                      },
                    ),
                    // Remove from waiting list
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                        color: AppColors.redText,
                      ),
                      tooltip: 'حذف من قائمة الانتظار',
                      onPressed: () {
                        context.read<MatchesBloc>().add(
                          CancelRegistrationRequested(
                            matchId: match.id,
                            playerId: reg.playerId,
                          ),
                        );
                      },
                    ),
                  ] else if (isMe && onCancelMyRegistration != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 18,
                        color: AppColors.redText,
                      ),
                      tooltip: 'إلغاء الانتظار',
                      onPressed: onCancelMyRegistration,
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
}
