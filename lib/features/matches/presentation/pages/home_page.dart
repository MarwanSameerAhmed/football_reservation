import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_cubit.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../notifications/presentation/widgets/notification_bell_button.dart';
import '../../../players/presentation/bloc/players_bloc.dart';
import '../../../players/presentation/bloc/players_state.dart';
import '../../../players/presentation/widgets/player_card.dart';
import '../../../polls/domain/entities/poll_entity.dart';
import '../../../polls/presentation/bloc/polls_bloc.dart';
import '../../../polls/presentation/bloc/polls_event.dart';
import '../../../polls/presentation/bloc/polls_state.dart';
import '../../../polls/presentation/widgets/poll_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDark = context.isDarkMode;

    return KickoffResponsiveShell(
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
              vertical: context.verticalPadding,
            ),
            children: [
              // Top User Greeting & Controls (matching Screen 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.isArabic ? 'مرحباً 👋' : 'Hello 👋',
                          style: context.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            final user = authState is Authenticated
                                ? authState.user
                                : null;
                            final name =
                                user?.displayName ??
                                (context.l10n.isArabic
                                    ? 'مروان سمير'
                                    : 'Marwan Sameer');
                            final role = user?.role ?? UserRole.admin;

                            return Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Text(
                                  name,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                KickoffBadge(
                                  label: context.l10n.isArabic
                                      ? role.labelArabic
                                      : role.labelEnglish,
                                  variant: role.isAdmin
                                      ? BadgeVariant.success
                                      : BadgeVariant.neutral,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Quick Controls: Notifications, Theme Toggle, Language & Auth Account
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const NotificationBellButton(),
                      const SizedBox(width: 4),
                      KickoffCircleButton(
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        onPressed: () => themeCubit.toggleTheme(),
                        size: context.responsive<double>(
                          standard: 40.0,
                          compact: 36.0,
                        ),
                        tooltip: 'تغيير المظهر',
                      ),
                      const SizedBox(width: 6),
                      KickoffCircleButton(
                        icon: Icons.language_rounded,
                        onPressed: () => themeCubit.toggleLanguage(),
                        size: context.responsive<double>(
                          standard: 40.0,
                          compact: 36.0,
                        ),
                        tooltip: 'تغيير اللغة',
                      ),
                      const SizedBox(width: 6),
                      KickoffCircleButton(
                        icon: Icons.login_rounded,
                        onPressed: () => context.push('/sign-in'),
                        size: context.responsive<double>(
                          standard: 40.0,
                          compact: 36.0,
                        ),
                        tooltip: 'تسجيل الدخول / تبديل الحساب',
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Search bar with green filter icon (matching Screen 2)
              KickoffSearchField(onChanged: (val) {}, onFilterTap: () {}),

              const SizedBox(height: 24),

              // "Recommended for you" Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.isArabic
                          ? 'المباراة القادمة المقترحة'
                          : 'Recommended for you',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(context.l10n.seeAll),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Large Hero Card (matching Screen 2)
              KickoffHeroCard(
                title: context.l10n.isArabic
                    ? 'ملعب النخبة الدولي'
                    : 'Elite Turf Arena',
                subtitle: context.l10n.isArabic
                    ? 'المنطقة المركزية • 0.8 كم'
                    : 'Downtown District • 0.8 km',
                rating: '4.9',
                fee: '90 دقيقة',
                distanceOrDate: '0.8 km',
                onTap: () => context.push('/match-details'),
              ),

              const SizedBox(height: 28),

              // Section: Court Vibe Check / Matches List (matching Screen 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.isArabic
                          ? 'حالة المباريات الأسبوعية'
                          : 'Court Vibe Check',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(context.l10n.seeAll),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              KickoffListCard(
                title: context.l10n.isArabic
                    ? 'مباراة الجمعة الكبرى'
                    : 'Victory Turf Ground',
                subtitle: context.l10n.isArabic
                    ? 'ملعب بارك • 1.2 كم'
                    : 'East Park • 1.2 km',
                badgeLabel: context.l10n.isArabic
                    ? '🟢 مكتمل تقريباً'
                    : '🟢 Quiet',
                badgeVariant: BadgeVariant.success,
                extraInfo: context.l10n.isArabic
                    ? 'باقي 4 مقاعد'
                    : '• 4 slots free',
                onTap: () => context.push('/reserve'),
              ),

              const SizedBox(height: 12),

              KickoffListCard(
                title: context.l10n.isArabic
                    ? 'كلاسيكو الثلاثاء'
                    : 'Sky Turf BD',
                subtitle: context.l10n.isArabic
                    ? 'ملعب غولشان • 2.8 كم'
                    : 'Gulshan • 2.8 km',
                badgeLabel: context.l10n.isArabic ? '🟡 حماسي' : '🟡 Moderate',
                badgeVariant: BadgeVariant.warning,
                extraInfo: context.l10n.isArabic
                    ? 'باقي مقعدان'
                    : '• 2 slots free',
                onTap: () => context.push('/reserve'),
              ),

              const SizedBox(height: 28),

              // Section: Active Polls & Voting Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.isArabic
                          ? 'استطلاعات الرأي والتصويت 📋'
                          : 'Active Polls & Voting',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/polls'),
                    child: Text(context.l10n.seeAll),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              BlocBuilder<PollsBloc, PollsState>(
                builder: (context, pollsState) {
                  if (pollsState is PollsLoaded &&
                      pollsState.polls.isNotEmpty) {
                    PollEntity latestActive = pollsState.polls.first;
                    for (final p in pollsState.polls) {
                      if (p.isActive) {
                        latestActive = p;
                        break;
                      }
                    }

                    return BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final currentUserId = authState is Authenticated
                            ? authState.user.id
                            : 'admin_1';
                        final isAdmin =
                            authState is Authenticated &&
                            authState.user.role == UserRole.admin;

                        return PollCard(
                          poll: latestActive,
                          currentUserId: currentUserId,
                          isAdmin: isAdmin,
                          onVoteOption: (option) {
                            context.read<PollsBloc>().add(
                              CastVoteRequested(
                                pollId: latestActive.id,
                                optionId: option.id,
                                userId: currentUserId,
                              ),
                            );
                          },
                          onClosePoll: () {
                            context.read<PollsBloc>().add(
                              ClosePollRequested(latestActive.id),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 20),

              // Quick Leaderboards Banner Card
              KickoffCard(
                padding: const EdgeInsets.all(16),
                onTap: () => context.push('/statistics'),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDarkElevated
                            : AppColors.meadowTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.leaderboard_rounded,
                        color: AppColors.turfGreenDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'لوحة صدارة المجموعة 🏆',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'قائمة الهدافين، صناع اللعب، وأفضل الحراس',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section: Top Squad Players & Technical Ratings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.isArabic
                          ? 'أبرز لاعبي المجموعة وتقييماتهم'
                          : 'Squad Players & Ratings',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/players'),
                    child: Text(context.l10n.seeAll),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quick preview of top players
              BlocBuilder<PlayersBloc, PlayersState>(
                builder: (context, state) {
                  if (state is PlayersLoaded && state.allPlayers.isNotEmpty) {
                    final previewPlayers = state.allPlayers.take(2).toList();
                    return Column(
                      children: previewPlayers.map((player) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: PlayerCard(
                            player: player,
                            onTap: () => context.push(
                              '/player-details/${player.id}',
                              extra: player,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 100), // Spacing for floating bottom bar
            ],
          ),
        ),
        bottomNavigationBar: KickoffBottomNavBar(
          currentIndex: _navIndex,
          onTap: (index) {
            setState(() => _navIndex = index);
            if (index == 2) {
              context.push('/players');
            } else if (index == 3) {
              context.push('/polls');
            }
          },
          items: [
            NavItemData(icon: Icons.home_filled, label: context.l10n.home),
            NavItemData(
              icon: Icons.calendar_today_rounded,
              label: context.l10n.matches,
            ),
            NavItemData(
              icon: Icons.people_alt_rounded,
              label: context.l10n.isArabic ? 'اللاعبون' : 'Players',
            ),
            NavItemData(
              icon: Icons.poll_rounded,
              label: context.l10n.isArabic ? 'التصويت' : 'Polls',
            ),
          ],
        ),
      ),
    );
  }
}
