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
                color: isDark
                    ? const Color(0xFF26332B)
                    : const Color(0xFFEAF5EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFF164E3D),
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
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF6B7280),
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
                foregroundColor: AppColors.redText,
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
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF5EF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Color(0xFF164E3D),
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
                      color: isDark
                          ? const Color(0xFF22382C)
                          : const Color(0xFFEAF5EF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E4E3E)
                            : const Color(0xFFC7E2D2),
                      ),
                    ),
                    child: const Text(
                      'معتمدة رسمياً ✓',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF164E3D),
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
                color: isDark
                    ? const Color(0xFF1C2721)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E4E3E)
                      : const Color(0xFFBBF7D0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.sports_soccer_rounded,
                        size: 16,
                        color: Color(0xFF164E3D),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'أنت تلعب ضمن: ${playerTeam.name} (${playerTeam.bibColor})',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFF164E3D),
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
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF3B2D12)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF78350F)
                                  : const Color(0xFFFCD34D),
                            ),
                          ),
                          child: Text(
                            '👑 كابتن الفريق: ${playerTeam.captain!.name}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFFCD34D)
                                  : const Color(0xFF92400E),
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
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E3329)
                                      : const Color(0xFFEAF5EF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF2E4E3E)
                                        : const Color(0xFFC7E2D2),
                                  ),
                                ),
                                child: Text(
                                  '🧤 دورك في الحراسة: الدورة #$turn',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF86EFAC)
                                        : const Color(0xFF164E3D),
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
                      ? (isDark
                            ? const Color(0xFF213027)
                            : const Color(0xFFE8F5EE))
                      : (isDark
                            ? AppColors.surfaceDarkElevated
                            : AppColors.canvasLight),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUserInThisTeam
                        ? const Color(0xFF164E3D)
                        : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
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
                                        ? const Color(0xFF164E3D)
                                        : (isDark
                                              ? Colors.white
                                              : AppColors.darkSlate),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (team.captain != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF3B2D12)
                                        : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '👑 ${team.captain!.name}',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xFFFCD34D)
                                          : const Color(0xFF92400E),
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
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playerNames.isNotEmpty ? playerNames : 'قيد التوزيع',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF4B5563),
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
