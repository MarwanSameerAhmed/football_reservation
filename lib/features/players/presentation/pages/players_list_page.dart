import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../bloc/players_bloc.dart';
import '../bloc/players_event.dart';
import '../bloc/players_state.dart';
import '../widgets/player_card.dart';

class PlayersListPage extends StatefulWidget {
  const PlayersListPage({super.key});

  @override
  State<PlayersListPage> createState() => _PlayersListPageState();
}

class _PlayersListPageState extends State<PlayersListPage> {
  final _searchController = TextEditingController();

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
    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: KickoffTopBar(
          title: context.l10n.isArabic
              ? 'قائمة اللاعبين وتقييم المهارات'
              : 'Players & Skill Ratings',
          showBackButton: false,
        ),
        body: Column(
          children: [
            // Search field
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 8.0,
              ),
              child: KickoffSearchField(
                controller: _searchController,
                hintText: context.l10n.isArabic
                    ? 'ابحث بالاسم أو اللقب...'
                    : 'Search player or nickname...',
                onChanged: (val) {
                  context.read<PlayersBloc>().add(
                    SearchPlayersQueryChanged(val),
                  );
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
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
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
                      ...PlayerPosition.values.map((pos) {
                        final isSelected = selectedPosition == pos;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
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

            const SizedBox(height: 8),

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
                    return const AppEmptyStateWidget(
                      title: 'لا يوجد لاعبون مسجلون',
                      message:
                          'لم يتم العثور على أي لاعبين يطابقون خيارات البحث الحالية.',
                    );
                  } else if (state is PlayersLoaded) {
                    final players = state.filteredPlayers;

                    if (players.isEmpty) {
                      return const AppEmptyStateWidget(
                        title: 'لا توجد نتائج',
                        message:
                            'لم يتم العثور على أي لاعبين في هذا المركز أو بهذا الاسم.',
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.horizontalPadding,
                        vertical: 12.0,
                      ),
                      itemCount: players.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        ),
      ),
    );
  }
}
