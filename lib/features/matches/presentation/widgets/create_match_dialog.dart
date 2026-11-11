import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/match_status.dart';
import '../../../../core/enums/poll_type.dart';
import '../../../../core/extensions/context_extensions.dart';
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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: matchesBloc),
          BlocProvider.value(value: pollsBloc),
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
  final _titleController = TextEditingController(
    text: 'مباراة الجمعة الكبرى (3 فرق)',
  );
  final _pitchController = TextEditingController(text: 'ملعب النخبة الدولي');
  final _locationController = TextEditingController(text: 'حي النخيل • الرياض');

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
      registrationOpensAt: _scheduleRegistrationOpen ? _registrationOpensAt : null,
      createdAt: DateTime.now(),
      confirmedPlayers: const [],
      waitingList: const [],
    );

    context.read<MatchesBloc>().add(CreateMatchRequested(newMatch));

    if (_enableMotmPoll) {
      final motmPoll = PollEntity(
        id: 'poll_motm_${newMatch.id}',
        matchId: newMatch.id,
        matchDetails: '${newMatch.title} • ${newMatch.pitchName}',
        title: 'رجل المباراة 🌟',
        description: 'تصويت رجل المباراة لمواجهة: ${newMatch.title}',
        type: PollType.manOfTheMatch,
        options: const [
          PollOptionEntity(
            id: 'opt_1',
            text: 'مروان سمير',
            subtitle: 'صانع ألعاب',
            voterUserIds: [],
          ),
          PollOptionEntity(
            id: 'opt_2',
            text: 'فهد الدوسري',
            subtitle: 'حارس مرمى',
            voterUserIds: [],
          ),
          PollOptionEntity(
            id: 'opt_3',
            text: 'عمر الشهري',
            subtitle: 'قلب دفاع',
            voterUserIds: [],
          ),
          PollOptionEntity(
            id: 'opt_4',
            text: 'سفيان العلي',
            subtitle: 'القناص',
            voterUserIds: [],
          ),
        ],
        creatorId: 'admin_1',
        allowMultipleVotes: false,
        closesAt: matchDateTime.add(const Duration(days: 2)),
        isClosed: false,
        isLockedUntilMatchEnds: true,
        createdAt: DateTime.now(),
      );
      context.read<PollsBloc>().add(CreatePollRequested(motmPoll));
    }

    Navigator.of(context).pop();

    context.showSuccessToast('تم إنشاء المباراة واستطلاع رجل المباراة بنجاح ⚽📢');
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
                decoration: InputDecoration(
                  labelText: 'اسم المباراة',
                  prefixIcon: const Icon(Icons.sports_soccer_rounded),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2E3D34) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2E3D34) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // Pitch Name
              TextFormField(
                controller: _pitchController,
                decoration: InputDecoration(
                  labelText: 'اسم الملعب',
                  prefixIcon: const Icon(Icons.stadium_rounded),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2E3D34) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2E3D34) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'موقع الملعب / الحي',
                  prefixIcon: const Icon(Icons.location_on_rounded),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2E3D34) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2E3D34) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // Date & Time Selectors Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF2E3D34) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
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
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF2E3D34) : const Color(0xFFCBD5E1),
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
              ),
              const SizedBox(height: 18),

              // Recurring Weekly Switch Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B241E)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2E3D34)
                        : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.turfGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sync_rounded,
                        color: Color(0xFF164E3D),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تكرار الحجز أسبوعياً 🔄',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'تثبيت موعد ومكان المباراة أسبوعياً بنفس اليوم والتوقيت',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isRecurringWeekly,
                      activeColor: AppColors.turfGreen,
                      onChanged: (val) =>
                          setState(() => _isRecurringWeekly = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // MOTM Poll Switch Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B241E)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2E3D34)
                        : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.turfGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.military_tech_rounded,
                        color: Color(0xFF164E3D),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'استطلاع رجل المباراة (MOTM) ⭐',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'يُنشأ مقفلاً تلقائياً حتى نهاية اللقاء وتسجيل النتيجة',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _enableMotmPoll,
                      activeColor: AppColors.turfGreen,
                      onChanged: (val) => setState(() => _enableMotmPoll = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Auto Lineup Generation Switch Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B241E)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2E3D34)
                        : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.turfGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF164E3D),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'توليد تلقائي للفرق (قبل المباراة بساعة) ⏰🤖',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isAutoLineupEnabled
                                ? 'يتم توزيع الفرق ذكياً وإرسال إشعار للمشاركين قبل ساعة، أو إيقافه للتوزيع اليدوي'
                                : 'توزيع التشكيلات يدوي فقط بواسطة الكابتن',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAutoLineupEnabled,
                      activeColor: AppColors.turfGreen,
                      onChanged: (val) =>
                          setState(() => _isAutoLineupEnabled = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Scheduled Registration Opening Time
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _scheduleRegistrationOpen
                        ? AppColors.turfGreen
                        : (isDark ? const Color(0xFF2E3D34) : const Color(0xFFCBD5E1)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_send_rounded,
                          color: _scheduleRegistrationOpen
                              ? AppColors.turfGreen
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'تحديد موعد لاحق لفتح باب الحجز ⏰',
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
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _scheduleRegistrationOpen,
                          activeColor: AppColors.turfGreen,
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
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_registrationOpensAt),
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
                              icon: const Icon(Icons.access_time_rounded, size: 16),
                              label: Text(
                                'توقيت الفتح: ${TimeOfDay.fromDateTime(_registrationOpensAt).format(context)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
    );
  }
}
