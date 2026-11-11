import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/poll_type.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/kickoff_action_button.dart';
import '../../../../core/presentation/widgets/kickoff_bottom_sheet_shell.dart';
import '../../domain/entities/poll_entity.dart';
import '../../domain/entities/poll_option_entity.dart';

/// Interactive modal bottom sheet for creating match scheduling, MOTM, or general polls.
class CreatePollSheet extends StatefulWidget {
  final String? matchId;
  final ValueChanged<PollEntity> onCreatePoll;

  const CreatePollSheet({super.key, this.matchId, required this.onCreatePoll});

  static Future<void> show(
    BuildContext context, {
    String? matchId,
    required ValueChanged<PollEntity> onCreatePoll,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CreatePollSheet(matchId: matchId, onCreatePoll: onCreatePoll),
    );
  }

  @override
  State<CreatePollSheet> createState() => _CreatePollSheetState();
}

class _CreatePollSheetState extends State<CreatePollSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  PollType _selectedType = PollType.matchScheduling;

  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _applyTypeDefaults(PollType.matchScheduling);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyTypeDefaults(PollType type) {
    _selectedType = type;
    for (final c in _optionControllers) {
      c.dispose();
    }
    _optionControllers.clear();

    switch (type) {
      case PollType.matchScheduling:
        _titleController.text = 'تصويت موعد ومكان المباراة القادمة ⚽';
        _descriptionController.text =
            'حدد الموعد والمكان الأنسب لمشاركتك لاعتماد حجز الصالة رسمياً.';
        _optionControllers.addAll([
          TextEditingController(text: 'الجمعة 08:00 مساءً - صالة النخبة المغطاة'),
          TextEditingController(text: 'السبت 07:30 مساءً - صالة أرينا المغطاة'),
          TextEditingController(text: 'الخميس 09:00 مساءً - ملعب بارك الخارجي'),
        ]);
        break;

      case PollType.manOfTheMatch:
        _titleController.text = 'تصويت رجل المباراة 🌟';
        _descriptionController.text =
            'صوت لأفضل لاعب قدم أداءً حاسماً ومميزاً في مواجهة الأسبوع.';
        _optionControllers.addAll([
          TextEditingController(text: 'مروان سمير (صانع ألعاب) ⚙️'),
          TextEditingController(text: 'فهد الدوسري (حارس مرمى) 🧤'),
          TextEditingController(text: 'عمر الشهري (قلب دفاع) 🛡️'),
          TextEditingController(text: 'سفيان العلي (مهاجم هداف) 🎯'),
        ]);
        break;

      case PollType.general:
        _titleController.text = 'استطلاع رأي عام للمجموعة 🗳️';
        _descriptionController.text =
            'شاركنا رأيك في موضوع المجموعة لتحسين التنظيم والمشاركة.';
        _optionControllers.addAll([
          TextEditingController(text: 'موافق تماماً 👍'),
          TextEditingController(text: 'غير موافق 👎'),
          TextEditingController(text: 'أقترح خياراً بديلاً 💡'),
        ]);
        break;
    }
  }

  void _onTypeChanged(PollType newType) {
    if (_selectedType == newType) return;
    setState(() {
      _applyTypeDefaults(newType);
    });
  }

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .map(
          (text) => PollOptionEntity(
            id: 'opt_${DateTime.now().microsecondsSinceEpoch}_${text.hashCode}',
            text: text,
          ),
        )
        .toList();

    if (options.length < 2) {
      context.showWarningToast('يجب توفير خيارين على الأقل للاستطلاع');
      return;
    }

    final poll = PollEntity(
      id: 'poll_${DateTime.now().millisecondsSinceEpoch}',
      matchId: widget.matchId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _selectedType,
      options: options,
      creatorId: 'admin_1',
      allowMultipleVotes: false,
      closesAt: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now(),
    );

    widget.onCreatePoll(poll);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return KickoffBottomSheetShell(
      title: 'إنشاء استطلاع رأي جديد',
      subtitle: 'شارك المجموعة في اختيار المواعيد أو التصويت لرجل المباراة',
      icon: Icons.how_to_vote_rounded,
      heightFactor: 0.85,
      bottomAction: KickoffActionButton(
        label: 'نشر الاستطلاع للمجموعة 📋',
        onPressed: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type Selector Chips with High Contrast & Clear Active State
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PollType.values.map((type) {
                final isSelected = type == _selectedType;
                final cs = Theme.of(context).colorScheme;
                final activeAccent =
                    isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;
                return ChoiceChip(
                  label: Text(
                    type.labelArabic,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? activeAccent
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: activeAccent.withValues(
                    alpha: isDark ? 0.16 : 0.12,
                  ),
                  backgroundColor: cs.surfaceContainer,
                  checkmarkColor: activeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected
                          ? activeAccent
                          : cs.outlineVariant.withValues(alpha: 0.7),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) _onTypeChanged(type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Title
            AppTextField(
              label: 'عنوان الاستطلاع',
              hint: _selectedType == PollType.manOfTheMatch
                  ? 'مثال: تصويت رجل المباراة'
                  : (_selectedType == PollType.matchScheduling
                      ? 'مثال: موعد كلاسيكو الجمعة القادم'
                      : 'مثال: استطلاع عام لأعضاء الفريق'),
              controller: _titleController,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'العنوان مطلوب' : null,
            ),
            const SizedBox(height: 12),

            // Description
            AppTextField(
              label: 'تفاصيل إضافية (اختياري)',
              hint: 'ملاحظات حول التصويت أو موعد الإغلاق...',
              controller: _descriptionController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Options Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedType == PollType.manOfTheMatch
                        ? 'المرشحون للتصويت (2 إلى 6)'
                        : 'خيارات التصويت (2 إلى 6)',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_optionControllers.length < 6)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _addOption,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(
                      _selectedType == PollType.manOfTheMatch
                          ? 'إضافة مرشح'
                          : 'إضافة خيار',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Dynamic Options List
            ...List.generate(_optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        hint: _selectedType == PollType.manOfTheMatch
                            ? 'اسم اللاعب أو المرشح #${index + 1}'
                            : 'الخيار رقم ${index + 1}',
                        controller: _optionControllers[index],
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'الخيار مطلوب'
                            : null,
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          color: AppColors.redText,
                        ),
                        onPressed: () => _removeOption(index),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
