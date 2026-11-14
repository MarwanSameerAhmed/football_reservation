import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/statistics_category.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/motion/kickoff_motion.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../statistics/presentation/bloc/statistics_bloc.dart';
import '../../../statistics/presentation/bloc/statistics_event.dart';
import '../../../statistics/presentation/bloc/statistics_state.dart';
import '../../../statistics/presentation/widgets/group_summary_card.dart';
import '../../../statistics/presentation/widgets/leaderboard_podium.dart';
import '../../../statistics/presentation/widgets/leaderboard_rank_tile.dart';
import '../bloc/players_bloc.dart';
import '../bloc/players_event.dart';
import '../bloc/players_state.dart';
import '../widgets/add_player_dialog.dart';
import '../widgets/player_card.dart';

class PlayersListPage extends StatefulWidget {
  const PlayersListPage({super.key});

  @override
  State<PlayersListPage> createState() => _PlayersListPageState();
}

class _PlayersListPageState extends State<PlayersListPage> {
  final _searchController = TextEditingController();
  int _activeSegment = 0; // 0: Squad List, 1: Leaderboard

  @override
  void initState() {
    super.initState();
    context.read<PlayersBloc>().add(const LoadPlayersRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isAdmin = user?.role == UserRole.admin;

    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: KickoffTopBar(
          title: _activeSegment == 0
              ? (context.l10n.isArabic
                    ? 'قائمة لاعبي المجموعة'
                    : 'Squad Roster')
              : (context.l10n.isArabic
                    ? 'لوحة صدارة المجموعة'
                    : 'Leaderboard & Stats'),
          showBackButton: false,
          actions: [
            if (isAdmin && _activeSegment == 0)
              KickoffCircleButton(
                icon: Icons.person_add_rounded,
                tooltip: 'إضافة لاعب جديد للمجموعة',
                size: 40,
                onPressed: () => AddPlayerDialog.show(context),
              ),
            if (_activeSegment == 1)
              KickoffCircleButton(
                icon: Icons.refresh_rounded,
                tooltip: 'تحديث لوحة الصدارة',
                size: 40,
                onPressed: () => context.read<StatisticsBloc>().add(
                  const LoadStatisticsRequested(),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Segmented Switcher: [ قائمة اللاعبين | لوحة الصدارة ]
            _buildSegmentedTabBar(context, isDark),

            // Content Area depending on active segment
            Expanded(
              child: _activeSegment == 0
                  ? _buildPlayersTab(context, isDark)
                  : _buildLeaderboardTab(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context, bool isDark) {
    final cs = context.colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalPadding,
        vertical: 8.0,
      ),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.7),
            width: 1.0,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth = constraints.maxWidth / 2;
            return Stack(
              children: [
                // 1. Smooth Animated Sliding Thumb (tam_app AppSegmentedTabBar)
                AnimatedAlign(
                  duration: KickoffMotion.accessible(
                    context,
                    KickoffMotion.controlGlide,
                  ),
                  curve: KickoffMotion.emphasized,
                  alignment: _activeSegment == 0
                      ? AlignmentDirectional.centerStart
                      : AlignmentDirectional.centerEnd,
                  child: SizedBox(
                    width: segmentWidth,
                    height: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: isDark
                            ? Border.all(color: cs.outlineVariant, width: 0.8)
                            : null,
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                    ),
                  ),
                ),

                // 2. Interactive Segment Buttons
                Row(
                  children: [
                    _buildSegmentButton(
                      index: 0,
                      label: 'قائمة اللاعبين',
                      icon: Icons.groups_rounded,
                      isDark: isDark,
                    ),
                    _buildSegmentButton(
                      index: 1,
                      label: 'لوحة الصدارة',
                      icon: Icons.emoji_events_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _activeSegment == index;
    final cs = context.colorScheme;

    final selectedTextColor = isDark ? cs.onSurface : cs.primary;
    final unselectedTextColor = cs.onSurfaceVariant;
    final textColor = isSelected ? selectedTextColor : unselectedTextColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.5),
          onTap: () {
            if (_activeSegment != index) {
              setState(() => _activeSegment = index);
              if (index == 1) {
                context.read<StatisticsBloc>().add(
                  const LoadStatisticsRequested(),
                );
              }
            }
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Search field
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: 4.0,
          ),
          child: KickoffSearchField(
            controller: _searchController,
            hintText: context.l10n.isArabic
                ? 'ابحث بالاسم أو اللقب...'
                : 'Search player or nickname...',
            onChanged: (val) {
              context.read<PlayersBloc>().add(SearchPlayersQueryChanged(val));
            },
            showFilterButton: false,
          ),
        ),

        // Horizontal Position Filter Chips
        BlocBuilder<PlayersBloc, PlayersState>(
          builder: (context, state) {
            final selectedPosition = state is PlayersLoaded
                ? state.selectedPosition
                : null;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 6.0,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: KickoffChoiceChip(
                      label: context.l10n.isArabic ? 'الكل' : 'All',
                      isSelected: selectedPosition == null,
                      onTap: () {
                        context.read<PlayersBloc>().add(
                          const FilterPlayersByPosition(null),
                        );
                      },
                    ),
                  ),
                  ...PlayerPosition.values
                      .where((pos) => pos != PlayerPosition.goalkeeper)
                      .map((pos) {
                        final isSelected = selectedPosition == pos;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: KickoffChoiceChip(
                            label: context.l10n.isArabic
                                ? pos.labelArabic
                                : pos.labelEnglish,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<PlayersBloc>().add(
                                FilterPlayersByPosition(pos),
                              );
                            },
                          ),
                        );
                      }),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 4),

        // Players list area
        Expanded(
          child: BlocBuilder<PlayersBloc, PlayersState>(
            builder: (context, state) {
              if (state is PlayersLoading) {
                return const AppLoadingWidget(
                  message: 'جاري تحميل قائمة اللاعبين...',
                );
              } else if (state is PlayersErrorState) {
                return AppErrorWidget(
                  message: state.errorMessage,
                  onRetry: () {
                    context.read<PlayersBloc>().add(
                      const LoadPlayersRequested(),
                    );
                  },
                );
              } else if (state is PlayersEmptyState) {
                return AppEmptyStateWidget(
                  title: 'لا يوجد لاعبون مسجلون بعد',
                  message:
                      'ابدأ بإضافة أول لاعب في مجموعتك لتوليد رابط الدعوة وحساب إحصائياته.',
                  actionLabel: 'إضافة لاعب للمجموعة',
                  onAction: () => AddPlayerDialog.show(context),
                );
              } else if (state is PlayersLoaded) {
                final players = state.filteredPlayers;

                if (players.isEmpty) {
                  return AppEmptyStateWidget(
                    title: state.allPlayers.isEmpty
                        ? 'لا يوجد لاعبون مسجلون بعد'
                        : 'لا توجد نتائج مطابقة',
                    message: state.allPlayers.isEmpty
                        ? 'ابدأ بإضافة رفاقك للمجموعة وتحديد مراكزهم وقدمهم المفضلة.'
                        : 'لم يتم العثور على أي لاعبين في هذا المركز أو بهذا الاسم.',
                    actionLabel: state.allPlayers.isEmpty
                        ? 'إضافة لاعب جديد'
                        : null,
                    onAction: state.allPlayers.isEmpty
                        ? () => AddPlayerDialog.show(context)
                        : null,
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.horizontalPadding,
                    vertical: 8.0,
                  ),
                  itemCount: players.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return PlayerCard(
                      player: player,
                      onTap: () => context.push(
                        '/player-details/${player.id}',
                        extra: player,
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, bool isDark) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state is StatisticsLoading || state is StatisticsInitial) {
          return const AppLoadingWidget(
            message: 'جاري تحميل لوحة المتصدرين...',
          );
        }

        if (state is StatisticsErrorState) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () => context.read<StatisticsBloc>().add(
              const LoadStatisticsRequested(),
            ),
          );
        }

        if (state is StatisticsEmptyState) {
          return AppEmptyStateWidget(
            title: 'لا تتوفر إحصائيات حتى الآن',
            message:
                'سيتم احتساب الإحصائيات والمتصدرين بمجرد تسجيل نتائج المباريات.',
            actionLabel: 'تحديث',
            onAction: () => context.read<StatisticsBloc>().add(
              const LoadStatisticsRequested(),
            ),
          );
        }

        if (state is! StatisticsLoaded) {
          return const SizedBox.shrink();
        }

        final statsState = state;
        final ranked = statsState.rankedPlayers.take(5).toList();
        final topThree = ranked.take(3).toList();
        final restRanked = ranked.length > 3
            ? ranked.skip(3).take(2).toList()
            : [];

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: 12,
          ),
          children: [
            // 1. Group Totals Summary Card
            GroupSummaryCard(leaderboard: statsState.leaderboard),
            const SizedBox(height: 16),

            // 2. Category Selector Bar (Excluding clean sheets)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: StatisticsCategory.values
                    .where((c) => c != StatisticsCategory.cleanSheets)
                    .map((cat) {
                      final isSelected = cat == statsState.selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: KickoffChoiceChip(
                          label: cat.labelArabic,
                          isSelected: isSelected,
                          height: 38,
                          onTap: () {
                            context.read<StatisticsBloc>().add(
                              CategoryFilterChanged(cat),
                            );
                          },
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Top 3 Podium
            if (topThree.isNotEmpty) ...[
              LeaderboardPodium(
                topThree: topThree,
                category: statsState.selectedCategory,
              ),
              const SizedBox(height: 16),
            ],

            // 4. Remaining Ranked Players
            if (restRanked.isNotEmpty) ...[
              ...List.generate(restRanked.length, (i) {
                final player = restRanked[i];
                final rank = i + 4;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: LeaderboardRankTile(
                    player: player,
                    rank: rank,
                    category: statsState.selectedCategory,
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }
}
