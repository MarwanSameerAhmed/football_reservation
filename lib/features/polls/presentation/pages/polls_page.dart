import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_circle_button.dart';
import '../../../../core/presentation/widgets/kickoff_responsive_shell.dart';
import '../../../../core/presentation/widgets/kickoff_top_bar.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../bloc/polls_bloc.dart';
import '../bloc/polls_event.dart';
import '../bloc/polls_state.dart';
import '../widgets/create_poll_sheet.dart';
import '../widgets/poll_card.dart';

class PollsPage extends StatefulWidget {
  final String? matchId;

  const PollsPage({super.key, this.matchId});

  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  int _selectedFilterIndex = 0; // 0: All, 1: Active Only, 2: Closed Only

  @override
  void initState() {
    super.initState();
    context.read<PollsBloc>().add(LoadPollsRequested(matchId: widget.matchId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isAdmin = user?.role == UserRole.admin;
    final currentUserId = user?.id ?? 'admin_1';

    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: KickoffTopBar(
          title: 'استطلاعات الرأي والتصويت',
          showBackButton: false,
          actions: [
            if (isAdmin)
              KickoffCircleButton(
                icon: Icons.add_rounded,
                tooltip: 'إنشاء تصويت جديد',
                size: 40,
                onPressed: () {
                  CreatePollSheet.show(
                    context,
                    matchId: widget.matchId,
                    onCreatePoll: (poll) {
                      context.read<PollsBloc>().add(CreatePollRequested(poll));
                    },
                  );
                },
              ),
          ],
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: () {
                  CreatePollSheet.show(
                    context,
                    matchId: widget.matchId,
                    onCreatePoll: (poll) {
                      context.read<PollsBloc>().add(CreatePollRequested(poll));
                    },
                  );
                },
                backgroundColor: isDark
                    ? AppColors.turfGreenNeon
                    : AppColors.primaryEmerald,
                foregroundColor:
                    isDark ? AppColors.canvasDark : Colors.white,
                icon: const Icon(Icons.poll_rounded),
                label: const Text(
                  'طرح استطلاع جديد',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : null,
        body: BlocConsumer<PollsBloc, PollsState>(
          listener: (context, state) {
            if (state is PollsLoaded && state.feedbackMessage != null) {
              context.showSuccessToast(state.feedbackMessage!);
            }
          },
          builder: (context, state) {
            if (state is PollsInitial || state is PollsLoading) {
              return const AppLoadingWidget(
                message: 'جاري تحميل الاستطلاعات...',
              );
            }

            if (state is PollsErrorState) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<PollsBloc>().add(
                    LoadPollsRequested(matchId: widget.matchId),
                  );
                },
              );
            }

            if (state is PollsEmptyState) {
              return AppEmptyStateWidget(
                title: 'لا توجد استطلاعات رأي حالياً',
                message:
                    'سيتم نشر استطلاعات المواعيد، واختيار الملاعب، وجائزة رجل المباراة هنا.',
                actionLabel: isAdmin ? 'إنشاء استطلاع جديد' : 'تحديث القائمة',
                onAction: () {
                  if (isAdmin) {
                    CreatePollSheet.show(
                      context,
                      matchId: widget.matchId,
                      onCreatePoll: (poll) {
                        context.read<PollsBloc>().add(
                          CreatePollRequested(poll),
                        );
                      },
                    );
                  } else {
                    context.read<PollsBloc>().add(
                      LoadPollsRequested(matchId: widget.matchId),
                    );
                  }
                },
              );
            }

            if (state is! PollsLoaded) {
              return const AppLoadingWidget(
                message: 'جاري تحميل الاستطلاعات...',
              );
            }

            final pollsState = state;
            var displayedPolls = pollsState.polls;
            if (_selectedFilterIndex == 1) {
              displayedPolls = displayedPolls.where((p) => p.isActive).toList();
            } else if (_selectedFilterIndex == 2) {
              displayedPolls = displayedPolls
                  .where((p) => !p.isActive)
                  .toList();
            }

            final activeCount = pollsState.polls
                .where((p) => p.isActive)
                .length;

            return Column(
              children: [
                // Quick Category Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        0,
                        'الكل (${pollsState.polls.length})',
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        1,
                        'المتاحة للتصويت ($activeCount)',
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(2, 'المنتهية والمحسومة', isDark),
                    ],
                  ),
                ),

                // Polls Feed
                Expanded(
                  child: displayedPolls.isEmpty
                      ? const AppEmptyStateWidget(
                          title: 'لا توجد نتائج مطابقة',
                          message: 'لا توجد استطلاعات في هذا القسم حالياً.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: displayedPolls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final poll = displayedPolls[index];
                            return PollCard(
                              poll: poll,
                              currentUserId: currentUserId,
                              isAdmin: isAdmin,
                              onVoteOption: (option) {
                                context.read<PollsBloc>().add(
                                  CastVoteRequested(
                                    pollId: poll.id,
                                    optionId: option.id,
                                    userId: currentUserId,
                                  ),
                                );
                              },
                              onClosePoll: () {
                                context.read<PollsBloc>().add(
                                  ClosePollRequested(poll.id),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald)
                : cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : cs.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppColors.canvasDark : Colors.white)
                  : cs.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
