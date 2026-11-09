import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
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
    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: KickoffTopBar(
          title: 'استطلاعات الرأي والتصويت',
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final isAdmin =
                    authState is Authenticated &&
                    authState.user.role == UserRole.admin;
                if (!isAdmin) return const SizedBox.shrink();

                return KickoffCircleButton(
                  icon: Icons.add_rounded,
                  tooltip: 'إنشاء استطلاع جديد',
                  onPressed: () {
                    CreatePollSheet.show(
                      context,
                      matchId: widget.matchId,
                      onCreatePoll: (poll) {
                        context.read<PollsBloc>().add(
                          CreatePollRequested(poll),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<PollsBloc, PollsState>(
          listener: (context, state) {
            if (state is PollsLoaded && state.feedbackMessage != null) {
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
                    'سيتم نشر استطلاعات تحديد المواعيد وجائزة رجل المباراة هنا.',
                actionLabel: 'تحديث القائمة',
                onAction: () {
                  context.read<PollsBloc>().add(
                    LoadPollsRequested(matchId: widget.matchId),
                  );
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

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final currentUserId = authState is Authenticated
                    ? authState.user.id
                    : 'admin_1';
                final isAdmin =
                    authState is Authenticated &&
                    authState.user.role == UserRole.admin;

                return Column(
                  children: [
                    // Filter Chips Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'الكل (${pollsState.polls.length})',
                              0,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'المتاحة للتصويت (${pollsState.polls.where((p) => p.isActive).length})',
                              1,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip('المنتهية', 2),
                          ],
                        ),
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
                                  const SizedBox(height: 16),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilterIndex = index);
      },
    );
  }
}
