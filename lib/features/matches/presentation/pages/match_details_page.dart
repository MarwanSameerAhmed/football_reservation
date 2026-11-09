import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';
import '../bloc/matches_state.dart';
import '../widgets/match_result_card.dart';
import '../widgets/match_roster_view.dart';
import '../widgets/match_status_badge.dart';
import '../widgets/record_result_sheet.dart';

class MatchDetailsPage extends StatefulWidget {
  final String? matchId;

  const MatchDetailsPage({super.key, this.matchId});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.matchId != null) {
      context.read<MatchesBloc>().add(SelectMatchRequested(widget.matchId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffResponsiveShell(
      child: BlocConsumer<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is MatchesLoaded && state.successMessage != null) {
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
                        state.successMessage!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is MatchesErrorState) {
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
                      Icons.error_outline_rounded,
                      color: AppColors.redText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const Scaffold(
              body: AppLoadingWidget(message: 'جاري تحميل تفاصيل المباراة...'),
            );
          }

          if (state is MatchesLoaded) {
            final match =
                state.selectedMatch ??
                (state.matches.isNotEmpty ? state.matches.first : null);

            if (match != null) {
              return Scaffold(
                appBar: KickoffTopBar(
                  title: context.l10n.isArabic
                      ? 'تفاصيل المباراة الأسبوعية'
                      : 'Match Details',
                  actions: [
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final isAdmin =
                            authState is Authenticated &&
                            authState.user.role == UserRole.admin;
                        if (!isAdmin) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: KickoffCircleButton(
                            icon: Icons.sports_score_rounded,
                            onPressed: () {
                              RecordResultSheet.show(
                                context,
                                match: match,
                                onSaveResult: (result) {
                                  context.read<MatchesBloc>().add(
                                    RecordMatchResultRequested(result),
                                  );
                                },
                              );
                            },
                            size: 40,
                            tooltip: 'تسجيل النتيجة الرسمية',
                          ),
                        );
                      },
                    ),
                    KickoffCircleButton(
                      icon: Icons.auto_awesome_rounded,
                      onPressed: () =>
                          context.push('/team-generator', extra: match),
                      size: 40,
                      tooltip: 'توليد الفرق الذكية',
                    ),
                    const SizedBox(width: 8),
                    KickoffCircleButton(
                      icon: _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: _isFavorite ? Colors.red : null,
                      onPressed: () =>
                          setState(() => _isFavorite = !_isFavorite),
                      size: 40,
                      tooltip: 'المفضلة',
                    ),
                  ],
                ),
                body: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.horizontalPadding,
                    vertical: 12.0,
                  ),
                  children: [
                    // Hero Stadium Visual (matching Screen 1)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusLarge,
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2E4D25),
                                    Color(0xFF142410),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stadium_rounded,
                                      size: 64,
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      match.pitchName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Floating distance pill
                        Positioned(
                          top: 14,
                          left: context.isRtl ? 14 : null,
                          right: context.isRtl ? null : 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusCircular,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.near_me_rounded,
                                  size: 13,
                                  color: AppColors.darkSlate,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '0.8 km',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Status Badge on bottom-start
                        Positioned(
                          bottom: 14,
                          left: context.isRtl ? null : 14,
                          right: context.isRtl ? 14 : null,
                          child: MatchStatusBadge(
                            status: match.status,
                            availableSpots: match.availableSpots,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Title & Fee Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                match.title,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      match.location,
                                      style: context.textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${match.maxPlayers} لاعباً',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.turfGreenNeon
                                : AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),

                    // Match Result Card (if completed/recorded)
                    if (match.result != null) ...[
                      const SizedBox(height: 18),
                      MatchResultCard(result: match.result!),
                    ],

                    const SizedBox(height: 20),

                    // Pitch Dimensions and Surface Card
                    KickoffCard(
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDarkElevated
                                  : AppColors.canvasLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.straighten_rounded,
                              color: isDark
                                  ? AppColors.turfGreenNeon
                                  : AppColors.turfGreenDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'أبعاد ونوع الملعب',
                                  style: context.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${match.pitchDimensions} • ${match.courtType}',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Smart Team Generator CTA Card
                    KickoffCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () =>
                          context.push('/team-generator', extra: match),
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
                              Icons.auto_awesome_rounded,
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
                                  'المولد الذكي للفرق',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'توزيع تكتيكي عادل ومتكافئ للقوى والمراكز',
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

                    const SizedBox(height: 24),

                    // Confirmed Squad & Waiting List
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final currentUserId = authState is Authenticated
                            ? authState.user.id
                            : 'admin_1';

                        return MatchRosterView(
                          match: match,
                          currentUserId: currentUserId,
                          onCancelMyRegistration: () {
                            context.read<MatchesBloc>().add(
                              CancelRegistrationRequested(
                                matchId: match.id,
                                playerId: currentUserId,
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),

                // Pinned Bottom Action Button
                bottomNavigationBar: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.horizontalPadding,
                      vertical: 12.0,
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final currentUserId = authState is Authenticated
                            ? authState.user.id
                            : 'admin_1';
                        final isRegistered = match.isPlayerRegistered(
                          currentUserId,
                        );
                        final reg = match.getPlayerRegistration(currentUserId);

                        if (isRegistered) {
                          final isWaiting = reg?.isWaiting ?? false;
                          return KickoffActionButton(
                            label: isWaiting
                                ? 'أنت في قائمة الانتظار #${reg?.queuePosition ?? 1} (إلغاء)'
                                : 'أنت مسجل أساسي ⚽ (إلغاء الحضور)',
                            circleColor: isWaiting
                                ? AppColors.amberText
                                : AppColors.redText,
                            customIcon: Icons.cancel_rounded,
                            onPressed: () {
                              context.read<MatchesBloc>().add(
                                CancelRegistrationRequested(
                                  matchId: match.id,
                                  playerId: currentUserId,
                                ),
                              );
                            },
                          );
                        }

                        final label = match.isSquadFull
                            ? 'التسجيل في قائمة الانتظار ⏳'
                            : 'تسجيل الحضور في التشكيلة الأساسية ⚽';

                        return KickoffActionButton(
                          label: label,
                          onPressed: () =>
                              context.push('/reserve', extra: match),
                        );
                      },
                    ),
                  ),
                ),
              );
            }
          }

          return Scaffold(
            appBar: KickoffTopBar(
              title: context.l10n.isArabic
                  ? 'تفاصيل المباراة'
                  : 'Match Details',
            ),
            body: AppErrorWidget(
              message: 'تعذر تحميل بيانات المباراة',
              onRetry: () =>
                  context.read<MatchesBloc>().add(const LoadMatchesRequested()),
            ),
          );
        },
      ),
    );
  }
}
