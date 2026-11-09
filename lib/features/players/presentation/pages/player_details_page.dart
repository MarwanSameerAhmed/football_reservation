import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../domain/entities/player_entity.dart';
import '../bloc/players_bloc.dart';
import '../bloc/players_state.dart';
import '../widgets/edit_skills_sheet.dart';
import '../widgets/player_position_badge.dart';
import '../widgets/player_skills_breakdown.dart';

class PlayerDetailsPage extends StatelessWidget {
  final PlayerEntity initialPlayer;

  const PlayerDetailsPage({super.key, required this.initialPlayer});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffResponsiveShell(
      child: BlocBuilder<PlayersBloc, PlayersState>(
        builder: (context, state) {
          // Keep player data reactive if updated via sheet
          PlayerEntity player = initialPlayer;
          if (state is PlayersLoaded) {
            for (final p in state.allPlayers) {
              if (p.id == initialPlayer.id) {
                player = p;
                break;
              }
            }
          }

          return Scaffold(
            appBar: KickoffTopBar(
              title: player.nickname != null
                  ? '${player.name} (${player.nickname})'
                  : player.name,
            ),
            body: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 16.0,
              ),
              children: [
                // Top Hero Card for Player
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusLarge,
                    ),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar with Player Initial
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.meadowTintDark
                              : AppColors.meadowTint,
                          border: Border.all(
                            color: isDark
                                ? AppColors.turfGreenNeon
                                : AppColors.turfGreen,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            player.name.trim().isNotEmpty
                                ? player.name.trim().substring(0, 1)
                                : '⚽',
                            style: context.textTheme.displayMedium?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.turfGreenNeon
                                  : AppColors.turfGreenDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        player.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (player.nickname != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'لقب اللاعب: "${player.nickname}"',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.turfGreenNeon
                                : AppColors.turfGreenDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Position Badges & Preferred Foot
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          PlayerPositionBadge(
                            position: player.primaryPosition,
                            showFullLabel: true,
                          ),
                          if (player.secondaryPosition != null)
                            PlayerPositionBadge(
                              position: player.secondaryPosition!,
                              showFullLabel: true,
                            ),
                          KickoffBadge(
                            label: 'القدم: ${player.preferredFoot.labelArabic}',
                            variant: BadgeVariant.neutral,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Match Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'المباريات',
                        value: '${player.matchesPlayed}',
                        icon: Icons.stadium_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'الأهداف',
                        value: '${player.goals}',
                        icon: Icons.sports_soccer_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'الصناعة',
                        value: '${player.assists}',
                        icon: Icons.handshake_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Technical Skills Breakdown
                PlayerSkillsBreakdown(player: player),

                const SizedBox(height: 32),
              ],
            ),

            // Bottom Action Bar: Admin Can Edit Skills, Players See Informational Note
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.horizontalPadding,
                  vertical: 12.0,
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final currentUser = authState is Authenticated
                        ? authState.user
                        : null;
                    final isAdmin = currentUser?.role == UserRole.admin;

                    if (isAdmin) {
                      return KickoffActionButton(
                        label: 'تعديل التقييم الفني للمهارات (Admin)',
                        customIcon: Icons.tune_rounded,
                        onPressed: () {
                          EditSkillsSheet.show(
                            context,
                            player: player,
                            userRole: UserRole.admin,
                          );
                        },
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircular,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 16,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'التقييم الفني معتمد حصراً من قبل إدارة المجموعة',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.turfGreenNeon : AppColors.turfGreenDark,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: context.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
