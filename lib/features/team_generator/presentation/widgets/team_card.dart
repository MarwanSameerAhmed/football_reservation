import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../domain/entities/generated_team_entity.dart';
import 'team_player_tile.dart';

class TeamCard extends StatelessWidget {
  final GeneratedTeamEntity team;
  final PlayerEntity? selectedPlayerForSwap;
  final ValueChanged<PlayerEntity> onPlayerTap;
  final Color accentColor;

  const TeamCard({
    super.key,
    required this.team,
    this.selectedPlayerForSwap,
    required this.onPlayerTap,
    this.accentColor = AppColors.turfGreen,
  });

  @override
  Widget build(BuildContext context) {
    return KickoffCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              KickoffBadge(
                label: '${team.players.length} لاعبين',
                variant: BadgeVariant.neutral,
              ),
              const SizedBox(width: 6),
              KickoffBadge(
                label: 'معدل ${team.averageRating.toStringAsFixed(1)}',
                variant: BadgeVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Players list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: team.players.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final player = team.players[index];
              final isSelected = selectedPlayerForSwap?.id == player.id;
              return TeamPlayerTile(
                player: player,
                isSelectedForSwap: isSelected,
                onTap: () => onPlayerTap(player),
              );
            },
          ),
        ],
      ),
    );
  }
}
