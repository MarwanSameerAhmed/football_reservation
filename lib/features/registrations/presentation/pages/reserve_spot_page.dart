import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../../../matches/presentation/bloc/matches_bloc.dart';
import '../../../matches/presentation/bloc/matches_event.dart';
import '../../../matches/presentation/bloc/matches_state.dart';

class ReserveSpotPage extends StatefulWidget {
  final MatchEntity? match;

  const ReserveSpotPage({super.key, this.match});

  @override
  State<ReserveSpotPage> createState() => _ReserveSpotPageState();
}

class _ReserveSpotPageState extends State<ReserveSpotPage> {
  String _selectedSlot = 'A1';
  int _selectedDateIndex = 2; // 07 Sat
  String _selectedTime = '19:00';
  PlayerPosition _selectedPosition = PlayerPosition.midfielder;
  bool _isSubmitting = false;

  final List<String> _slots = ['A1', 'B1', 'B2', 'C1', 'D1'];
  final List<Map<String, String>> _dates = [
    {'day': '05', 'label': 'الخميس'},
    {'day': '06', 'label': 'الجمعة'},
    {'day': '07', 'label': 'السبت'},
    {'day': '08', 'label': 'الأحد'},
    {'day': '09', 'label': 'الإثنين'},
  ];
  final List<String> _times = ['18:00', '19:00', '20:00', '21:00'];

  void _handleConfirm(MatchEntity match) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : 'admin_1';
    final userName = authState is Authenticated
        ? authState.user.displayName
        : 'مروان سمير';

    setState(() => _isSubmitting = true);

    context.read<MatchesBloc>().add(
      RegisterPlayerRequested(
        matchId: match.id,
        playerId: userId,
        playerName: userName,
        position: _selectedPosition,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KickoffResponsiveShell(
      child: BlocConsumer<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is MatchesLoaded && state.successMessage != null) {
            setState(() => _isSubmitting = false);
            context.pop();
          } else if (state is MatchesErrorState) {
            setState(() => _isSubmitting = false);
          }
        },
        builder: (context, state) {
          MatchEntity? effectiveMatch = widget.match;
          if (effectiveMatch == null && state is MatchesLoaded) {
            effectiveMatch =
                state.selectedMatch ??
                (state.matches.isNotEmpty ? state.matches.first : null);
          }

          final match = effectiveMatch;

          return Scaffold(
            appBar: KickoffTopBar(
              title: context.l10n.reserveYourCourt,
              actions: [
                KickoffCircleButton(
                  icon: Icons.info_outline_rounded,
                  onPressed: () {},
                  size: 40,
                  tooltip: 'معلومات الحجز',
                ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 12.0,
              ),
              children: [
                // ── Choose a Slot (matching Screen 3) ───────────────────────
                Text(
                  context.l10n.chooseSlot,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _slots.map((slot) {
                    final isSelected = _selectedSlot == slot;
                    return SizedBox(
                      width:
                          (context.screenWidth -
                              (context.horizontalPadding * 2) -
                              24) /
                          3,
                      child: KickoffChoiceChip(
                        label: slot,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedSlot = slot),
                        height: 52,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                // Legend Wrap (matching Screen 3)
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.change_history_rounded,
                          size: 14,
                          color: AppColors.turfGreenDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.isArabic
                              ? 'A,C: صالة مغطاة'
                              : '▲ A,C: Indoor',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.turfGreenDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wb_sunny_rounded,
                          size: 14,
                          color: AppColors.amberText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.isArabic
                              ? 'B,D: ملعب خارجي'
                              : '☀ B,D: Outdoor',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.amberText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Choose Date ─────────────────────────────────────────────
                Text(
                  context.l10n.chooseDate,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: List.generate(_dates.length, (index) {
                      final item = _dates[index];
                      final isSelected = _selectedDateIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: KickoffChoiceChip(
                          label: item['day']!,
                          subLabel: context.l10n.isArabic
                              ? item['label']
                              : ['Thu', 'Fri', 'Sat', 'Sun', 'Mon'][index],
                          isSelected: isSelected,
                          onTap: () =>
                              setState(() => _selectedDateIndex = index),
                          width: 64,
                          height: 72,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Choose a time ───────────────────────────────────────────
                Text(
                  context.l10n.chooseTime,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _times.map((time) {
                    final isSelected = _selectedTime == time;
                    return KickoffChoiceChip(
                      label: time,
                      icon: Icons.access_time_rounded,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedTime = time),
                      height: 48,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ── Tactical Playing Position for this Match ────────────────
                Text(
                  'مركزك التكتيكي في هذه المباراة:',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PlayerPosition.values.map((pos) {
                    final isSelected = _selectedPosition == pos;
                    return KickoffChoiceChip(
                      label: pos.labelArabic,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedPosition = pos),
                      height: 46,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
              ],
            ),

            // Pinned Bottom Action Button (Confirm Booking)
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.horizontalPadding,
                  vertical: 12.0,
                ),
                child: KickoffActionButton(
                  label: match != null && match.isSquadFull
                      ? 'تأكيد التسجيل في قائمة الانتظار ⏳'
                      : context.l10n.confirmBooking,
                  isLoading: _isSubmitting,
                  onPressed: match != null ? () => _handleConfirm(match) : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
