import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../../../core/utils/lineup_share_helper.dart';
import '../../../team_generator/domain/entities/generated_team_entity.dart';
import '../../../team_generator/domain/entities/team_lineup_entity.dart';
import '../../domain/entities/match_entity.dart';
import 'withdrawal_reason_dialog.dart';

/// Card displayed on the Home Page showing the officially approved & published
/// match lineup for the logged-in player.
class MatchLineupCard extends StatelessWidget {
  final MatchEntity match;
  final TeamLineupEntity? lineup;
  final String currentUserId;
  final String currentUserName;
  final VoidCallback? onTap;

  const MatchLineupCard({
    super.key,
    required this.match,
    this.lineup,
    required this.currentUserId,
    required this.currentUserName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = Theme.of(context).colorScheme;
    final emerald = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;
    final amber = isDark ? AppColors.amberNeon : AppColors.amberText;
    final isFinalized = lineup?.isFinalized ?? false;

    // Check if the player is assigned to any team
    GeneratedTeamEntity? playerTeam;
    if (lineup != null && isFinalized) {
      for (final team in lineup!.teams) {
        if (team.players.any(
          (p) =>
              p.userId == currentUserId ||
              p.id == currentUserId ||
              p.name == currentUserName,
        )) {
          playerTeam = team;
          break;
        }
      }
    }

    // Fallback default team if mock/demo
    playerTeam ??= (lineup != null && lineup!.teams.isNotEmpty)
        ? lineup!.teams.first
        : null;

    if (!isFinalized || lineup == null) {
      // Pending Distribution State
      return KickoffCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: emerald.withValues(alpha: isDark ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                color: emerald,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أنت مسجل في المباراة ✓',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'تشكيلة الفرق قيد الإعداد بواسطة الكابتن. سيصلك إشعار فوري عند صدورها!',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => WithdrawalReasonDialog.show(
                context,
                match: match,
                playerId: currentUserId,
                playerName: currentUserName,
              ),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppColors.redNeon : AppColors.redText,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              icon: const Icon(Icons.event_busy_rounded, size: 16),
              label: const Text(
                'اعتذار',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // Approved & Published Lineup State
    return KickoffCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: emerald.withValues(alpha: isDark ? 0.16 : 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        color: emerald,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'تشكيلات مباراتك المعتمدة 📋',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: emerald.withValues(alpha: isDark ? 0.16 : 0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: emerald.withValues(alpha: isDark ? 0.30 : 0.25),
                      ),
                    ),
                    child: Text(
                      'معتمدة رسمياً ✓',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: emerald,
                      ),
                    ),
                  ),
                  if (lineup != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.share_rounded,
                        size: 18,
                        color: Color(0xFF25D366),
                      ),
                      tooltip: 'مشاركة التشكيلات عبر واتساب 📲',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () => LineupShareHelper.copyLineupToClipboard(
                        context,
                        match: match,
                        lineup: lineup!,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User's Assigned Team Highlight Box
          if (playerTeam != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: emerald.withValues(alpha: isDark ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: emerald.withValues(alpha: isDark ? 0.30 : 0.24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sports_soccer_rounded,
                        size: 16,
                        color: emerald,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'أنت تلعب ضمن: ${playerTeam.name} (${playerTeam.bibColor})',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: emerald,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (playerTeam.captain != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: amber.withValues(alpha: isDark ? 0.16 : 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: amber.withValues(alpha: isDark ? 0.35 : 0.28),
                            ),
                          ),
                          child: Text(
                            '👑 كابتن الفريق: ${playerTeam.captain!.name}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: amber,
                            ),
                          ),
                        ),
                      Builder(
                        builder: (_) {
                          final me = playerTeam!.players
                              .where(
                                (p) =>
                                    p.userId == currentUserId ||
                                    p.id == currentUserId ||
                                    p.name == currentUserName,
                              )
                              .firstOrNull;
                          if (me != null) {
                            final turn = playerTeam.getGoalkeeperOrder(me.id);
                            if (turn > 0) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: emerald.withValues(
                                    alpha: isDark ? 0.16 : 0.10,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: emerald.withValues(
                                      alpha: isDark ? 0.30 : 0.24,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '🧤 دورك في الحراسة: الدورة #$turn',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: emerald,
                                  ),
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Teams Preview Grid / Columns
          Column(
            children: lineup!.teams.map((team) {
              final isUserInThisTeam = team.id == playerTeam?.id;
              final playerNames = team.players
                  .map((p) {
                    final isCapt = team.isCaptain(p.id);
                    final gkTurn = team.getGoalkeeperOrder(p.id);
                    final captSuffix = isCapt ? ' 👑' : '';
                    final gkSuffix = gkTurn > 0 ? ' [🧤#$gkTurn]' : '';
                    return '${p.name}$captSuffix$gkSuffix';
                  })
                  .join(' • ');

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUserInThisTeam
                      ? emerald.withValues(alpha: isDark ? 0.14 : 0.08)
                      : cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUserInThisTeam
                        ? emerald.withValues(alpha: 0.65)
                        : cs.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  '${team.name} (${team.bibColor})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isUserInThisTeam
                                        ? emerald
                                        : cs.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (team.captain != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: amber.withValues(
                                      alpha: isDark ? 0.16 : 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '👑 ${team.captain!.name}',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: amber,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '${team.players.length} لاعبين',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playerNames.isNotEmpty ? playerNames : 'قيد التوزيع',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
