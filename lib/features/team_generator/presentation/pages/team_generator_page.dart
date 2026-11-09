import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_action_button.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../../../core/presentation/widgets/kickoff_responsive_shell.dart';
import '../../../../core/presentation/widgets/kickoff_top_bar.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../../players/presentation/bloc/players_bloc.dart';
import '../../../players/presentation/bloc/players_event.dart';
import '../../../players/presentation/bloc/players_state.dart';
import '../bloc/team_generator_bloc.dart';
import '../bloc/team_generator_event.dart';
import '../bloc/team_generator_state.dart';
import '../widgets/balance_indicator_bar.dart';
import '../widgets/team_card.dart';

class TeamGeneratorPage extends StatefulWidget {
  final MatchEntity match;

  const TeamGeneratorPage({super.key, required this.match});

  @override
  State<TeamGeneratorPage> createState() => _TeamGeneratorPageState();
}

class _TeamGeneratorPageState extends State<TeamGeneratorPage> {
  @override
  void initState() {
    super.initState();
    final playersState = context.read<PlayersBloc>().state;
    if (playersState is! PlayersLoaded) {
      context.read<PlayersBloc>().add(const LoadPlayersRequested());
    }
  }

  List<PlayerEntity> _extractMatchPlayers(List<PlayerEntity> allPlayers) {
    // Collect confirmed player IDs from match
    final confirmedIds = widget.match.confirmedPlayers
        .map((r) => r.playerId)
        .toSet();

    if (confirmedIds.isNotEmpty) {
      final matched = allPlayers
          .where((p) => confirmedIds.contains(p.id))
          .toList();
      if (matched.isNotEmpty) return matched;
    }

    // Fallback if registrations not populated with mock IDs: pick first N players
    if (allPlayers.isEmpty) return [];
    final targetCount = allPlayers.length >= 2
        ? widget.match.maxPlayers.clamp(2, allPlayers.length)
        : allPlayers.length;
    return allPlayers.take(targetCount).toList();
  }

  void _triggerGeneration(List<PlayerEntity> players) {
    if (players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب توفر لاعبين اثنين على الأقل لتوليد الفرق'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<TeamGeneratorBloc>().add(
      GenerateBalancedTeamsRequested(
        matchId: widget.match.id,
        players: players,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: KickoffTopBar(
          title: 'المولد الذكي للفرق',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'إعادة التوزيع',
              onPressed: () {
                final playersState = context.read<PlayersBloc>().state;
                if (playersState is PlayersLoaded) {
                  final players = _extractMatchPlayers(playersState.allPlayers);
                  _triggerGeneration(players);
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<TeamGeneratorBloc, TeamGeneratorState>(
          listener: (context, state) {
            if (state is TeamGeneratorSuccess &&
                state.feedbackMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.darkSlate,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.turfGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.feedbackMessage!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TeamGeneratorLoading) {
              return AppLoadingWidget(
                message: state.message ?? 'جاري التوليد...',
              );
            }

            if (state is TeamGeneratorErrorState) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () {
                  final playersState = context.read<PlayersBloc>().state;
                  if (playersState is PlayersLoaded) {
                    final players = _extractMatchPlayers(
                      playersState.allPlayers,
                    );
                    _triggerGeneration(players);
                  }
                },
              );
            }

            return BlocBuilder<PlayersBloc, PlayersState>(
              builder: (context, playersState) {
                if (playersState is PlayersLoading) {
                  return const AppLoadingWidget(
                    message: 'جاري تحميل قائمة اللاعبين...',
                  );
                }

                final allPlayers = playersState is PlayersLoaded
                    ? playersState.allPlayers
                    : <PlayerEntity>[];
                final matchPlayers = _extractMatchPlayers(allPlayers);

                final lineup = (state is TeamGeneratorSuccess)
                    ? state.currentLineup
                    : null;
                final selectedForSwap = (state is TeamGeneratorSuccess)
                    ? state.selectedPlayerForSwap
                    : null;
                final isSaving =
                    (state is TeamGeneratorSuccess) && state.isSaving;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Match summary banner
                      KickoffCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDarkElevated
                                    : AppColors.meadowTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sports_soccer_rounded,
                                color: AppColors.turfGreenDark,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.match.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${matchPlayers.length} لاعباً جاهزاً للتوزيع',
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            KickoffBadge(
                              label: lineup?.isFinalized == true
                                  ? 'تشكيلة معتمدة'
                                  : 'مسودة تكتيكية',
                              variant: lineup?.isFinalized == true
                                  ? BadgeVariant.success
                                  : BadgeVariant.warning,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // If no lineup yet, show generator prompt
                      if (lineup == null) ...[
                        const SizedBox(height: 16),
                        KickoffCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: AppColors.meadowTint,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 32,
                                  color: AppColors.turfGreenDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'توليد تشكيلة عادلة ومتكافئة',
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'يقوم الخوارزم الذكي بتوزيع حراس المرمى والمدافعين وخط الوسط والهجوم مع مراعاة التقييم الفني لمنع تفوق فريق على الآخر.',
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 20),
                              KickoffActionButton(
                                label: 'توليد الفرق الآن ⚡',
                                onPressed: () =>
                                    _triggerGeneration(matchPlayers),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Tactical balance bar
                        BalanceIndicatorBar(teams: lineup.teams),
                        const SizedBox(height: 12),

                        // Swap hint / active selection banner
                        if (selectedForSwap != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.amberTint,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.amberText.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.swap_calls_rounded,
                                  color: AppColors.amberText,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'محدد: ${selectedForSwap.name}. اضغط على لاعب من أي فريق آخر لإتمام التبديل.',
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.amberText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: AppColors.amberText,
                                  ),
                                  onPressed: () {
                                    context.read<TeamGeneratorBloc>().add(
                                      const ClearSwapSelectionRequested(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                        // Teams (dynamically render all generated teams)
                        ...List.generate(lineup.teams.length, (index) {
                          final team = lineup.teams[index];
                          final colors = [
                            AppColors.turfGreen,
                            isDark
                                ? Colors.lightBlueAccent
                                : const Color(0xFF0284C7),
                            isDark
                                ? AppColors.textSecondaryLight
                                : AppColors.darkSlate,
                          ];
                          final color = colors[index % colors.length];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: TeamCard(
                              team: team,
                              accentColor: color,
                              selectedPlayerForSwap: selectedForSwap,
                              onPlayerTap: (player) {
                                context.read<TeamGeneratorBloc>().add(
                                  SelectPlayerForSwapRequested(player),
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 10),

                        // Finalize Action Button
                        KickoffActionButton(
                          label: lineup.isFinalized
                              ? 'تم اعتماد التشكيلة الرسمية ✓'
                              : 'اعتماد وحفظ التشكيلة للمباراة ⚽',
                          isLoading: isSaving,
                          onPressed: lineup.isFinalized
                              ? null
                              : () {
                                  context.read<TeamGeneratorBloc>().add(
                                    SaveFinalLineupRequested(lineup),
                                  );
                                },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
