import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_action_button.dart';
import '../../../../core/presentation/widgets/kickoff_badge.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../../../core/presentation/widgets/kickoff_circle_button.dart';
import '../../../../core/presentation/widgets/kickoff_responsive_shell.dart';
import '../../../../core/presentation/widgets/kickoff_top_bar.dart';
import '../../../../core/utils/lineup_share_helper.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../../../matches/presentation/bloc/matches_bloc.dart';
import '../../../matches/presentation/bloc/matches_state.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../../players/presentation/bloc/players_bloc.dart';
import '../../../players/presentation/bloc/players_event.dart';
import '../../../players/presentation/bloc/players_state.dart';
import '../bloc/team_generator_bloc.dart';
import '../bloc/team_generator_event.dart';
import '../bloc/team_generator_state.dart';
import '../widgets/balance_indicator_bar.dart';
import '../widgets/select_match_for_lineup_sheet.dart';
import '../widgets/team_card.dart';

class TeamGeneratorPage extends StatefulWidget {
  final MatchEntity match;

  const TeamGeneratorPage({super.key, required this.match});

  @override
  State<TeamGeneratorPage> createState() => _TeamGeneratorPageState();
}

class _TeamGeneratorPageState extends State<TeamGeneratorPage> {
  late MatchEntity _currentMatch;

  @override
  void initState() {
    super.initState();
    _currentMatch = widget.match;
    final playersState = context.read<PlayersBloc>().state;
    if (playersState is! PlayersLoaded) {
      context.read<PlayersBloc>().add(const LoadPlayersRequested());
    }
  }

  void _showMatchSelectorSheet(BuildContext context) {
    final matchesState = context.read<MatchesBloc>().state;
    final matches = matchesState is MatchesLoaded
        ? matchesState.matches
              .where((m) => m.status != MatchStatus.completed)
              .toList()
        : <MatchEntity>[];

    if (matches.isEmpty) {
      context.showWarningToast('لا توجد حجوزات أخرى متاحة حالياً.');
      return;
    }

    SelectMatchForLineupSheet.show(
      context,
      matches: matches,
      onSelectMatch: (selected) {
        setState(() {
          _currentMatch = selected;
        });
      },
    );
  }

  List<PlayerEntity> _extractMatchPlayers(List<PlayerEntity> allPlayers) {
    // Collect confirmed player IDs from match
    final confirmedIds = _currentMatch.confirmedPlayers
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
        ? _currentMatch.maxPlayers.clamp(2, allPlayers.length)
        : allPlayers.length;
    return allPlayers.take(targetCount).toList();
  }

  void _triggerGeneration(List<PlayerEntity> players) {
    if (players.length < 2) {
      context.showWarningToast('يجب توفر لاعبين اثنين على الأقل لتوليد الفرق');
      return;
    }

    context.read<TeamGeneratorBloc>().add(
      GenerateBalancedTeamsRequested(
        matchId: _currentMatch.id,
        players: players,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authState = context.watch<AuthBloc>().state;
    final isAdmin =
        authState is Authenticated && authState.user.role == UserRole.admin;

    if (!isAdmin) {
      return KickoffResponsiveShell(
        child: Scaffold(
          appBar: const KickoffTopBar(title: 'صلاحيات الإدارة 🛡️'),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.redTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: AppColors.redText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'صفحة مخصصة للكابتن فقط 🛡️',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'توليد وتوزيع الفرق وتعديل التشكيلات التكتيكية من صلاحيات كابتن ومسؤول المجموعة فقط. يمكنك الاطلاع على التشكيلة النهائية بعد اعتمادها ونشرها في الصفحة الرئيسية.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkText
                          : AppColors.ink,
                      foregroundColor: isDark
                          ? AppColors.ink
                          : Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('العودة للمباراة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return KickoffResponsiveShell(
      child: BlocConsumer<TeamGeneratorBloc, TeamGeneratorState>(
        listener: (context, state) {
          if (state is TeamGeneratorSuccess && state.feedbackMessage != null) {
            context.showSuccessToast(state.feedbackMessage!);
          }
        },
        builder: (context, state) {
          final lineup = (state is TeamGeneratorSuccess)
              ? state.currentLineup
              : null;
          final selectedForSwap = (state is TeamGeneratorSuccess)
              ? state.selectedPlayerForSwap
              : null;
          final isSaving = (state is TeamGeneratorSuccess) && state.isSaving;

          return Scaffold(
            appBar: KickoffTopBar(
              title: 'المولد الذكي للفرق',
              actions: [
                KickoffCircleButton(
                  icon: Icons.swap_horiz_rounded,
                  tooltip: 'تبديل الحجز',
                  size: 38,
                  onPressed: () => _showMatchSelectorSheet(context),
                ),
                const SizedBox(width: 6),
                KickoffCircleButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'إعادة التوزيع',
                  size: 38,
                  onPressed: () {
                    final playersState = context.read<PlayersBloc>().state;
                    if (playersState is PlayersLoaded) {
                      final players = _extractMatchPlayers(
                        playersState.allPlayers,
                      );
                      _triggerGeneration(players);
                    }
                  },
                ),
              ],
            ),
            body: Builder(
              builder: (context) {
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

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Match summary banner (Interactive to switch matches)
                          KickoffCard(
                            padding: const EdgeInsets.all(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showMatchSelectorSheet(context),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.indigoAccent.withValues(
                                        alpha: isDark ? 0.18 : 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: const Icon(
                                      Icons.sports_soccer_rounded,
                                      color: AppColors.indigoAccent,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _currentMatch.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13.5,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Icon(
                                              Icons.unfold_more_rounded,
                                              size: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${matchPlayers.length} لاعباً جاهزاً للتوزيع',
                                          style: context.textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
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
                                    decoration: BoxDecoration(
                                      color: AppColors.indigoAccent.withValues(
                                        alpha: isDark ? 0.18 : 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 32,
                                      color: AppColors.indigoAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'توليد تشكيلة عادلة ومتكافئة',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
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
                                isDark
                                    ? AppColors.turfGreenNeon
                                    : AppColors.primaryEmerald,
                                isDark
                                    ? Colors.lightBlueAccent
                                    : AppColors.blueAccent,
                                AppColors.indigoAccent,
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
                            const SizedBox(height: 8),

                            // 1. WhatsApp Lineup Share Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 1,
                                ),
                                onPressed: () =>
                                    LineupShareHelper.copyLineupToClipboard(
                                      context,
                                      match: _currentMatch,
                                      lineup: lineup,
                                    ),
                                icon: const Icon(Icons.share_rounded, size: 20),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'مشاركة التشكيلات عبر واتساب 📲',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 2. Finalize Action Button
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
          );
        },
      ),
    );
  }
}
