import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_bottom_sheet_shell.dart';
import '../../domain/entities/match_entity.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';

/// Modal dialog allowing a registered player to withdraw / excuse themselves
/// from an upcoming match with a specific reason and note sent to the Captain.
class WithdrawalReasonDialog extends StatefulWidget {
  final MatchEntity match;
  final String playerId;
  final String playerName;

  const WithdrawalReasonDialog({
    super.key,
    required this.match,
    required this.playerId,
    required this.playerName,
  });

  static Future<void> show(
    BuildContext context, {
    required MatchEntity match,
    required String playerId,
    required String playerName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<MatchesBloc>(),
        child: WithdrawalReasonDialog(
          match: match,
          playerId: playerId,
          playerName: playerName,
        ),
      ),
    );
  }

  @override
  State<WithdrawalReasonDialog> createState() => _WithdrawalReasonDialogState();
}

class _WithdrawalReasonDialogState extends State<WithdrawalReasonDialog> {
  final TextEditingController _noteController = TextEditingController();

  final List<String> _commonReasons = const [
    'إصابة رياضية 🤕',
    'ظرف عائلي طارئ 👨‍👩‍👧',
    'ارتباط عمل / دوام 💼',
    'سفر خارج المدينة ✈️',
    'وعكة صحية 🤒',
    'سبب آخر 📝',
  ];

  String _selectedReason = 'إصابة رياضية 🤕';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirmWithdrawal() {
    setState(() => _isSubmitting = true);

    final customNote = _noteController.text.trim();

    context.read<MatchesBloc>().add(
      CancelRegistrationRequested(
        matchId: widget.match.id,
        playerId: widget.playerId,
        playerName: widget.playerName,
        reason: _selectedReason,
        customNote: customNote.isNotEmpty ? customNote : null,
      ),
    );

    Navigator.of(context).pop();

    context.showSuccessToast(
      'تم تسجيل اعتذارك وإبلاغ الكابتن رسمياً ⚠️',
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffBottomSheetShell(
      title: 'الاعتذار والانسحاب من المباراة',
      subtitle: widget.match.title,
      icon: Icons.event_busy_rounded,
      heightFactor: 0.84,
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _confirmWithdrawal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redText,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'تأكيد الانسحاب وإبلاغ الكابتن ⚠️',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'تراجع (البقاء في التشكيلة الأساسية)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          final cs = Theme.of(context).colorScheme;
          final redAccent = isDark ? AppColors.redNeon : AppColors.redText;
          final amberAccent =
              isDark ? AppColors.amberNeon : AppColors.amberText;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Player friendly message
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Text(
                  'نأسف لعدم تمكنك من الحضور يا ${widget.playerName}! يرجى تحديد السبب ليصل إشعار للكابتن ليتمكن من ترتيب التشكيلة وتصعيد البدلاء.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Select Reason Chips
              const Text(
                'اختر سبب الاعتذار *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonReasons.map((reason) {
                  final isSelected = _selectedReason == reason;
                  return ChoiceChip(
                    label: Text(reason),
                    selected: isSelected,
                    selectedColor: redAccent.withValues(
                      alpha: isDark ? 0.16 : 0.10,
                    ),
                    backgroundColor: cs.surface,
                    side: BorderSide(
                      color: isSelected
                          ? redAccent
                          : cs.outlineVariant.withValues(alpha: 0.7),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? redAccent : cs.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedReason = reason);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Custom Note Field
              const Text(
                'ملاحظة إضافية للكابتن (اختياري)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'اذكر أي تفاصيل تود مشاركتها مع الكابتن...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkMuted
                        : const Color(0xFF4B5563),
                  ),
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notice about auto-waitlist promotion
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: amberAccent.withValues(alpha: isDark ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: amberAccent.withValues(alpha: isDark ? 0.35 : 0.30),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: amberAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'عند الانسحاب، سيتم إخلاء مكانك وتصعيد أول لاعب في قائمة الانتظار تلقائياً، وإشعار الكابتن بالسبب فوراً.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: amberAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}

