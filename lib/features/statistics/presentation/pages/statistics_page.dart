import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/statistics_category.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/states/app_states.dart';
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
          title: 'إحصائيات المجموعة والمتصدرين',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث الإحصائيات',
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
            final ranked = statsState.rankedPlayers;
            final topThree = ranked.take(3).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Group Totals Summary
                  GroupSummaryCard(leaderboard: statsState.leaderboard),
                  const SizedBox(height: 16),

                  // Category Selector Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: StatisticsCategory.values.map((cat) {
                        final isSelected = cat == statsState.selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ChoiceChip(
                            label: Text(cat.labelArabic),
                            selected: isSelected,
                            selectedColor: isDark
                                ? AppColors.turfGreenDark
                                : AppColors.meadowTint,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<StatisticsBloc>().add(
                                  CategoryFilterChanged(cat),
                                );
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Top 3 Podium
                  if (topThree.isNotEmpty) ...[
                    LeaderboardPodium(
                      topThree: topThree,
                      category: statsState.selectedCategory,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Full Ranked Leaderboard List
                  Text(
                    'الترتيب الكامل',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ranked.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final player = ranked[index];
                      return LeaderboardRankTile(
                        player: player,
                        rank: index + 1,
                        category: statsState.selectedCategory,
                      );
                    },
                  ),
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
