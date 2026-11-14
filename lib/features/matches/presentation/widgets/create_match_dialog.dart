import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/poll_type.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../../players/presentation/bloc/players_bloc.dart';
import '../../../players/presentation/bloc/players_state.dart';
import '../../../polls/domain/entities/poll_entity.dart';
import '../../../polls/domain/entities/poll_option_entity.dart';
import '../../../polls/presentation/bloc/polls_bloc.dart';
import '../../../polls/presentation/bloc/polls_event.dart';
import '../../../../core/presentation/widgets/kickoff_bottom_sheet_shell.dart';
import '../../domain/entities/match_entity.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';

/// Modal dialog for Captain/Admin to create an official weekly match.
class CreateMatchDialog extends StatefulWidget {
  const CreateMatchDialog({super.key});

  static Future<void> show(BuildContext context) {
    final matchesBloc = context.read<MatchesBloc>();
    final pollsBloc = context.read<PollsBloc>();
    final authBloc = context.read<AuthBloc?>();
    final playersBloc = context.read<PlayersBloc?>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: matchesBloc),
          BlocProvider.value(value: pollsBloc),
          if (authBloc != null) BlocProvider.value(value: authBloc),
          if (playersBloc != null) BlocProvider.value(value: playersBloc),
        ],
        child: const CreateMatchDialog(),
      ),
    );
  }

  @override
  State<CreateMatchDialog> createState() => _CreateMatchDialogState();
}

class _CreateMatchDialogState extends State<CreateMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _pitchController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 30);
  final int _maxPlayers = 18;
  bool _enableMotmPoll = true;
  bool _isRecurringWeekly = false;
  bool _isAutoLineupEnabled = true;
  bool _scheduleRegistrationOpen = false;
  DateTime _registrationOpensAt = DateTime.now().add(const Duration(hours: 2));

  @override
  void dispose() {
    _titleController.dispose();
    _pitchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final matchDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final newMatch = MatchEntity(
      id: 'match_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      pitchName: _pitchController.text.trim(),
      location: _locationController.text.trim(),
      matchDateTime: matchDateTime,
      maxPlayers: _maxPlayers,
      feePerPlayer: 0.0,
      status: MatchStatus.upcoming,
      isRecurringWeekly: _isRecurringWeekly,
      isAutoLineupEnabled: _isAutoLineupEnabled,
      registrationOpensAt: _scheduleRegistrationOpen
          ? _registrationOpensAt
          : null,
      createdAt: DateTime.now(),
      confirmedPlayers: const [],
      waitingList: const [],
    );

    context.read<MatchesBloc>().add(CreateMatchRequested(newMatch));

    if (_enableMotmPoll) {
      final authState = context.read<AuthBloc?>()?.state;
      final creatorId =
          authState is Authenticated ? authState.user.id : '';
      final playersState = context.read<PlayersBloc?>()?.state;
      final List<PlayerEntity> realPlayers = playersState is PlayersLoaded
          ? playersState.allPlayers
          : const <PlayerEntity>[];

      if (realPlayers.length >= 2) {
        final options = realPlayers
            .take(6)
            .map(
              (p) => PollOptionEntity(
                id: 'opt_${p.id}',
                text: p.name,
                subtitle: p.primaryPosition.labelArabic,
                voterUserIds: const [],
              ),
            )
            .toList();

        final motmPoll = PollEntity(
          id: 'poll_motm_${newMatch.id}',
          matchId: newMatch.id,
          matchDetails: '${newMatch.title} • ${newMatch.pitchName}',
          title: 'رجل المباراة 🌟',
          description: 'تصويت رجل المباراة لمواجهة: ${newMatch.title}',
          type: PollType.manOfTheMatch,
          options: options,
          creatorId: creatorId,
          allowMultipleVotes: false,
          closesAt: matchDateTime.add(const Duration(days: 2)),
          isClosed: false,
          isLockedUntilMatchEnds: true,
          createdAt: DateTime.now(),
        );
        context.read<PollsBloc>().add(CreatePollRequested(motmPoll));
      }
    }

    Navigator.of(context).pop();

    context.showSuccessToast(
      'تم إنشاء المباراة واستطلاع رجل المباراة بنجاح ⚽📢',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffBottomSheetShell(
      title: 'إنشاء مباراة جديدة (الكابتن)',
      subtitle: 'نظام 3 فرق • 18 لاعب (الكل يشارك ويحرس)',
      icon: Icons.add_task_rounded,
      heightFactor: 0.86,
      bottomAction: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark
                ? AppColors.turfGreenNeon
                : AppColors.turfGreen,
            foregroundColor: isDark ? AppColors.darkSlate : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 1,
          ),
          onPressed: _submit,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_soccer_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                _scheduleRegistrationOpen
                    ? 'جدولة المباراة ونشر الموعد ⏰'
                    : 'نشر المباراة وفتح الحجز ⚽',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'اسم المباراة',
                hintText: 'أدخل اسم أو عنوان المباراة',
                prefixIcon: Icon(Icons.sports_soccer_rounded),
              ),
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),

            // Pitch Name
            TextFormField(
              controller: _pitchController,
              decoration: const InputDecoration(
                labelText: 'اسم الملعب',
                hintText: 'أدخل اسم الملعب',
                prefixIcon: Icon(Icons.stadium_rounded),
              ),
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),

            // Location Field
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'موقع الملعب / الحي',
                hintText: 'أدخل موقع الملعب أو الحي',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            // Date & Time Selectors Row
            Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: cs.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.8),
                          ),
                        ),
                        onPressed: _pickDate,
                        icon: const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                        ),
                        label: Text(
                          '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: cs.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.8),
                          ),
                        ),
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time_rounded, size: 18),
                        label: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),

            // Recurring Weekly Switch Card
            _buildOptionToggleCard(
              context,
              isDark: isDark,
              icon: Icons.sync_rounded,
              accentColor: isDark
                  ? AppColors.turfGreenNeon
                  : AppColors.primaryEmerald,
              title: 'تكرار الحجز أسبوعياً 🔄',
              subtitle:
                  'تثبيت موعد ومكان المباراة أسبوعياً بنفس اليوم والتوقيت',
              value: _isRecurringWeekly,
              onChanged: (val) => setState(() => _isRecurringWeekly = val),
            ),
            const SizedBox(height: 12),

            // MOTM Poll Switch Card
            _buildOptionToggleCard(
              context,
              isDark: isDark,
              icon: Icons.military_tech_rounded,
              accentColor: isDark ? AppColors.amberNeon : AppColors.amberText,
              title: 'استطلاع رجل المباراة (MOTM) ',
              subtitle: 'يُنشأ مقفلاً تلقائياً حتى نهاية اللقاء وتسجيل النتيجة',
              value: _enableMotmPoll,
              onChanged: (val) => setState(() => _enableMotmPoll = val),
            ),
            const SizedBox(height: 12),

            // Auto Lineup Generation Switch Card
            _buildOptionToggleCard(
              context,
              isDark: isDark,
              icon: Icons.auto_awesome_rounded,
              accentColor: isDark
                  ? AppColors.indigoNeon
                  : AppColors.indigoAccent,
              title: 'توليد تلقائي للفرق (قبل المباراة بساعة)',
              subtitle: _isAutoLineupEnabled
                  ? 'يتم توزيع الفرق ذكياً وإرسال إشعار للمشاركين قبل ساعة، أو إيقافه للتوزيع اليدوي'
                  : 'توزيع التشكيلات يدوي فقط بواسطة الكابتن',
              value: _isAutoLineupEnabled,
              onChanged: (val) => setState(() => _isAutoLineupEnabled = val),
            ),
            const SizedBox(height: 12),

            // Scheduled Registration Opening Time
            Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                final accent = isDark
                    ? AppColors.blueNeon
                    : AppColors.blueAccent;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _scheduleRegistrationOpen
                          ? accent
                          : cs.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accent.withValues(
                                alpha: isDark ? 0.16 : 0.10,
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              Icons.schedule_send_rounded,
                              color: _scheduleRegistrationOpen
                                  ? accent
                                  : cs.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'تحديد موعد لاحق لفتح باب الحجز ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _scheduleRegistrationOpen
                                      ? 'يفتح الحجز تلقائياً في التوقيت المحدد مع إشعار تذكيري قبل 5 دقائق'
                                      : 'فتح الحجز فور نشر المباراة مباشرة',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _scheduleRegistrationOpen,
                            activeTrackColor: AppColors.blue,
                            activeColor: Colors.white,
                            inactiveThumbColor: isDark
                                ? AppColors.darkMuted
                                : Colors.white,
                            inactiveTrackColor: isDark
                                ? AppColors.surfaceDarkElevated
                                : const Color(0xFFE2E8F0),
                            trackOutlineColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            onChanged: (val) =>
                                setState(() => _scheduleRegistrationOpen = val),
                          ),
                        ],
                      ),
                      if (_scheduleRegistrationOpen) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      _registrationOpensAt,
                                    ),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _registrationOpensAt = DateTime(
                                        _registrationOpensAt.year,
                                        _registrationOpensAt.month,
                                        _registrationOpensAt.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  'توقيت الفتح: ${TimeOfDay.fromDateTime(_registrationOpensAt).format(context)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionToggleCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? (isDark
                    ? AppColors.blueNeon
                    : AppColors.blue.withValues(alpha: 0.6))
              : cs.outlineVariant.withValues(alpha: 0.7),
          width: value ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? accentColor.withValues(alpha: isDark ? 0.20 : 0.12)
                  : (isDark
                        ? AppColors.surfaceDarkElevated
                        : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: value ? accentColor : cs.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.5, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.blue,
            activeColor: Colors.white,
            inactiveThumbColor: isDark ? AppColors.darkMuted : Colors.white,
            inactiveTrackColor: isDark
                ? AppColors.surfaceDarkElevated
                : const Color(0xFFE2E8F0),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
