import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/poll_type.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/kickoff_action_button.dart';
import '../../domain/entities/poll_entity.dart';
import '../../domain/entities/poll_option_entity.dart';

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

  final List<TextEditingController> _optionControllers = [
    TextEditingController(text: 'الجمعة 08:00 مساءً - صالة النخبة'),
    TextEditingController(text: 'السبت 07:30 مساءً - صالة أرينا'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب توفير خيارين على الأقل للاستطلاع'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16.0,
        left: context.horizontalPadding,
        right: context.horizontalPadding,
        bottom: context.viewInsets.bottom + 24.0,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'إنشاء استطلاع رأي جديد',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Type Selector Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PollType.values.map((type) {
                  final isSelected = type == _selectedType;
                  return ChoiceChip(
                    label: Text(type.labelArabic),
                    selected: isSelected,
                    selectedColor: isDark
                        ? AppColors.turfGreenDark
                        : AppColors.meadowTint,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Title
              AppTextField(
                label: 'عنوان الاستطلاع',
                hint: 'مثال: موعد كلاسيكو الجمعة القادم',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'خيارات التصويت (2 إلى 6 خيارات)',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_optionControllers.length < 6)
                    TextButton.icon(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('إضافة خيار'),
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
                          hint: 'الخيار رقم ${index + 1}',
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
              const SizedBox(height: 20),

              // Submit Button
              KickoffActionButton(
                label: 'نشر الاستطلاع للمجموعة 📋',
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
