import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/statistics_category.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_circle_button.dart';
import '../../../../core/presentation/widgets/kickoff_responsive_shell.dart';
import '../../../../core/presentation/widgets/kickoff_top_bar.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import '../widgets/group_summary_card.dart';
import '../widgets/leaderboard_podium.dart';
import '../widgets/leaderboard_rank_tile.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsBloc>().add(const LoadStatisticsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: KickoffTopBar(
          title: 'لوحة الصدارة والإحصائيات 🏆',
          showBackButton: false,
          actions: [
            KickoffCircleButton(
              icon: Icons.refresh_rounded,
              tooltip: 'تحديث الإحصائيات',
              size: 40,
              onPressed: () {
                context.read<StatisticsBloc>().add(
                  const LoadStatisticsRequested(),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsInitial || state is StatisticsLoading) {
              return const AppLoadingWidget(
                message: 'جاري تحميل لوحة المتصدرين...',
              );
            }

            if (state is StatisticsErrorState) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<StatisticsBloc>().add(
                    const LoadStatisticsRequested(),
                  );
                },
              );
            }

            if (state is StatisticsEmptyState) {
              return AppEmptyStateWidget(
                title: 'لا تتوفر إحصائيات حتى الآن',
                message:
                    'سيتم احتساب الإحصائيات والمتصدرين بمجرد تسجيل نتائج المباريات.',
                actionLabel: 'تحديث',
                onAction: () {
                  context.read<StatisticsBloc>().add(
                    const LoadStatisticsRequested(),
                  );
                },
              );
            }

            if (state is! StatisticsLoaded) {
              return const AppLoadingWidget(
                message: 'جاري تحميل لوحة المتصدرين...',
              );
            }

            final statsState = state;
            final ranked = statsState.rankedPlayers.take(5).toList();
            final topThree = ranked.take(3).toList();
            final restRanked = ranked.length > 3
                ? ranked.skip(3).take(2).toList()
                : <dynamic>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Group Totals Summary Card
                  GroupSummaryCard(leaderboard: statsState.leaderboard),
                  const SizedBox(height: 16),

                  // 2. Creative Category Selector Bar (الهدافون، صناع اللعب، رجل المباراة)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        StatisticsCategory.goals,
                        StatisticsCategory.assists,
                        StatisticsCategory.motm,
                      ].map((cat) {
                        final isSelected = cat == statsState.selectedCategory;
                        final icon = switch (cat) {
                          StatisticsCategory.goals =>
                            Icons.sports_soccer_rounded,
                          StatisticsCategory.assists =>
                            Icons.assistant_photo_rounded,
                          StatisticsCategory.cleanSheets =>
                            Icons.shield_rounded,
                          StatisticsCategory.motm => Icons.star_rounded,
                        };

                        final cs = Theme.of(context).colorScheme;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            onTap: () {
                              context.read<StatisticsBloc>().add(
                                CategoryFilterChanged(cat),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.primary.withValues(
                                        alpha: isDark ? 0.18 : 0.10,
                                      )
                                    : cs.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? cs.primary
                                      : cs.outlineVariant,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: 16,
                                    color: isSelected
                                        ? cs.primary
                                        : cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.labelArabic,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? cs.primary
                                          : cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Top 3 3D Podium
                  if (topThree.isNotEmpty) ...[
                    LeaderboardPodium(
                      topThree: topThree,
                      category: statsState.selectedCategory,
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            size: 32,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'لا توجد إحصائيات مسجلة بعد',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ستظهر أسماء المتصدرين والأهداف والجوائز فور إنهاء وتسجيل أول نتيجة مباراة.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. Remaining Ranked Leaderboard List (#4 and below)
                  if (restRanked.isNotEmpty) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.format_list_numbered_rounded,
                          size: 18,
                          color: AppColors.turfGreen,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'بقية الترتيب العام',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restRanked.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final player = restRanked[index];
                        return LeaderboardRankTile(
                          player: player,
                          rank: index + 4,
                          category: statsState.selectedCategory,
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
