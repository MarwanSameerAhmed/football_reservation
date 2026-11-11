import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_responsive_shell.dart';
import '../../../../core/presentation/widgets/kickoff_top_bar.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../../../matches/presentation/bloc/matches_bloc.dart';
import '../../../matches/presentation/bloc/matches_event.dart';
import '../../../matches/presentation/bloc/matches_state.dart';

/// Realistic Match Attendance & RSVP Confirmation Page.
///
/// Eliminates confusing padel-style slot/date/time picking.
/// Directly displays fixed match schedule and enables 1-tap attendance RSVP.
class ReserveSpotPage extends StatefulWidget {
  final MatchEntity? match;

  const ReserveSpotPage({super.key, this.match});

  @override
  State<ReserveSpotPage> createState() => _ReserveSpotPageState();
}

class _ReserveSpotPageState extends State<ReserveSpotPage> {
  bool _isSubmitting = false;

  void _handleConfirm(MatchEntity match, String userId, String userName) {
    setState(() => _isSubmitting = true);

    context.read<MatchesBloc>().add(
      RegisterPlayerRequested(
        matchId: match.id,
        playerId: userId,
        playerName: userName,
        position: PlayerPosition.midfielder,
      ),
    );
  }

  void _handleCancel(MatchEntity match, String userId) {
    setState(() => _isSubmitting = true);

    context.read<MatchesBloc>().add(
      CancelRegistrationRequested(matchId: match.id, playerId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final userId = user?.id ?? 'admin_1';
    final userName = user?.displayName ?? 'مروان سمير';

    return KickoffResponsiveShell(
      child: BlocConsumer<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is MatchesLoaded && state.successMessage != null) {
            setState(() => _isSubmitting = false);
            context.showSuccessToast(state.successMessage!);
            context.pop();
          } else if (state is MatchesErrorState) {
            setState(() => _isSubmitting = false);
            context.showErrorToast(state.message);
          }
        },
        builder: (context, state) {
          MatchEntity? effectiveMatch = widget.match;
          if (effectiveMatch == null && state is MatchesLoaded) {
            effectiveMatch =
                state.selectedMatch ??
                (state.matches.isNotEmpty ? state.matches.first : null);
          }

          if (effectiveMatch == null) {
            return const Scaffold(
              body: Center(child: Text('لا تتوفر تفاصيل لهذه المباراة حالياً')),
            );
          }

          final match = effectiveMatch;
          final isConfirmed = match.confirmedPlayers.any(
            (p) => p.playerId == userId,
          );
          final isWaiting = match.waitingList.any((p) => p.playerId == userId);
          final waitingIndex = isWaiting
              ? match.waitingList.indexWhere((p) => p.playerId == userId) + 1
              : 0;

          final confirmedCount = match.confirmedPlayers.length;
          final maxPlayers = match.maxPlayers;
          final isFull = confirmedCount >= maxPlayers;
          final progress = (confirmedCount / (maxPlayers > 0 ? maxPlayers : 18))
              .clamp(0.0, 1.0);

          final dateStr = DateFormat(
            'EEEE d MMMM yyyy',
            'ar',
          ).format(match.matchDateTime);
          final timeStr = DateFormat(
            'hh:mm a',
            'ar',
          ).format(match.matchDateTime);

          return Scaffold(
            appBar: const KickoffTopBar(title: 'تأكيد الحضور للمباراة'),
            body: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 16.0,
              ),
              children: [
                // 1. Match Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusLarge,
                    ),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.turfGreen.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sports_soccer_rounded,
                              color: AppColors.turfGreen,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  match.title,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'نظام 3 فرق • 18 لاعب (الكل يشارك ويحرس)',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.turfGreenNeon
                                        : AppColors.turfGreenDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Location & Time Items
                      _buildInfoRow(
                        icon: Icons.stadium_rounded,
                        title: 'الملعب:',
                        value: '${match.pitchName} (${match.location})',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        icon: Icons.calendar_today_rounded,
                        title: 'الموعد:',
                        value: dateStr,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        icon: Icons.access_time_rounded,
                        title: 'التوقيت:',
                        value: '$timeStr (المدة: 90 دقيقة)',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Squad Attendance Status
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المقاعد المؤكدة: $confirmedCount / $maxPlayers',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            isFull
                                ? '${match.waitingList.length} في الانتظار ⏳'
                                : '${maxPlayers - confirmedCount} مقاعد متبقية',
                            style: TextStyle(
                              color: isFull
                                  ? Colors.orange
                                  : AppColors.turfGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? AppColors.surfaceDarkElevated
                              : AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFull ? Colors.orange : AppColors.turfGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'ملاحظة: التسجيل نهائي في قائمة الـ 18 لاعب، ويتم تقسيم اللاعبين إلى 3 فرق متوازنة بواسطة الكابتن.',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. User Action Area
                if (isConfirmed) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.meadowTintDark
                          : AppColors.meadowTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.turfGreen,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'أنت مسجل ومؤكد حضورك في هذه المباراة!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.redText,
                        side: const BorderSide(color: AppColors.redText),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => _handleCancel(match, userId),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text(
                        'اعتذار عن الحضور وإتاحة المقعد لغيري',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ] else if (isWaiting) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.hourglass_top_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'أنت حالياً في قائمة الانتظار برقم #$waitingIndex.\nسيتم تصعيدك تلقائياً وإشعارك في حال اعتذار أي لاعب.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.redText,
                        side: const BorderSide(color: AppColors.redText),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => _handleCancel(match, userId),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text(
                        'إلغاء الانضمام لقائمة الانتظار',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFull
                            ? Colors.orange
                            : (isDark
                                  ? AppColors.turfGreenNeon
                                  : AppColors.turfGreen),
                        foregroundColor: isFull
                            ? Colors.white
                            : (isDark ? AppColors.darkSlate : Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => _handleConfirm(match, userId, userName),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.touch_app_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  isFull
                                      ? 'انضمام لقائمة الانتظار'
                                      : 'تأكيد حضوري للمباراة الآن',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        context.push('/match-details', extra: match),
                    icon: const Icon(Icons.groups_rounded, size: 18),
                    label: const Text(
                      'مشاهدة قائمة اللاعبين والتشكيلة الحالية',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.turfGreenNeon : AppColors.turfGreenDark,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
