import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/kickoff_action_button.dart';
import '../../domain/entities/goal_event_entity.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_result_entity.dart';

class RecordResultSheet extends StatefulWidget {
  final MatchEntity match;
  final ValueChanged<MatchResultEntity> onSaveResult;

  const RecordResultSheet({
    super.key,
    required this.match,
    required this.onSaveResult,
  });

  static Future<void> show(
    BuildContext context, {
    required MatchEntity match,
    required ValueChanged<MatchResultEntity> onSaveResult,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          RecordResultSheet(match: match, onSaveResult: onSaveResult),
    );
  }

  @override
  State<RecordResultSheet> createState() => _RecordResultSheetState();
}

class _RecordResultSheetState extends State<RecordResultSheet> {
  int _scoreA = 0;
  int _scoreB = 0;
  final String _teamAName = 'الفريق الأول (الأخضر)';
  final String _teamBName = 'الفريق الثاني (الأبيض)';
  String? _selectedMotmPlayerName;
  final _notesController = TextEditingController();

  final List<GoalEventEntity> _goals = [];

  // Scorer addition fields
  final _scorerController = TextEditingController();
  final _assistController = TextEditingController();
  String _goalTeam = 'الفريق الأول (الأخضر)';

  @override
  void initState() {
    super.initState();
    final existing = widget.match.result;
    if (existing != null) {
      _scoreA = existing.teamAScore;
      _scoreB = existing.teamBScore;
      _selectedMotmPlayerName = existing.manOfTheMatchName;
      _notesController.text = existing.notes ?? '';
      _goals.addAll(existing.goals);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scorerController.dispose();
    _assistController.dispose();
    super.dispose();
  }

  void _addGoal() {
    final scorer = _scorerController.text.trim();
    if (scorer.isEmpty) return;

    final assist = _assistController.text.trim();
    final newGoal = GoalEventEntity(
      id: 'goal_${DateTime.now().microsecondsSinceEpoch}',
      scorerPlayerId: scorer.hashCode.toString(),
      scorerName: scorer,
      teamName: _goalTeam,
      assistPlayerName: assist.isNotEmpty ? assist : null,
      minute: 10 + (_goals.length * 12),
    );

    setState(() {
      _goals.add(newGoal);
      if (_goalTeam == _teamAName) {
        _scoreA++;
      } else {
        _scoreB++;
      }
      _scorerController.clear();
      _assistController.clear();
    });
  }

  void _submit() {
    final result = MatchResultEntity(
      id: widget.match.result?.id ?? 'res_${widget.match.id}',
      matchId: widget.match.id,
      teamAScore: _scoreA,
      teamBScore: _scoreB,
      teamAName: _teamAName,
      teamBName: _teamBName,
      goals: _goals,
      manOfTheMatchName: _selectedMotmPlayerName,
      isLocked: true,
      recordedAt: DateTime.now(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    widget.onSaveResult(result);
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
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'تسجيل وتثبيت نتيجة المباراة الرسمية',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Score Steppers
            Row(
              children: [
                // Team A
                Expanded(
                  child: _buildTeamScoreControl(
                    name: _teamAName,
                    color: AppColors.turfGreen,
                    score: _scoreA,
                    onIncrement: () => setState(() => _scoreA++),
                    onDecrement: () => setState(() {
                      if (_scoreA > 0) _scoreA--;
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    ':',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Team B
                Expanded(
                  child: _buildTeamScoreControl(
                    name: _teamBName,
                    color: isDark
                        ? AppColors.textSecondaryLight
                        : AppColors.darkSlate,
                    score: _scoreB,
                    onIncrement: () => setState(() => _scoreB++),
                    onDecrement: () => setState(() {
                      if (_scoreB > 0) _scoreB--;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Add Goal Section
            Text(
              'تسجيل الأهداف وصناعها (اختياري)',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hint: 'اسم الهداف',
                    controller: _scorerController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    hint: 'صانع الهدف',
                    controller: _assistController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                // Team Choice
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _goalTeam,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: [_teamAName, _teamBName].map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t, style: context.textTheme.bodySmall),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _goalTeam = v);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.turfGreen,
                    foregroundColor: AppColors.darkSlate,
                  ),
                  onPressed: _addGoal,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),

            if (_goals.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _goals.map((g) {
                  return Chip(
                    label: Text('${g.scorerName} ⚽ (${g.teamName})'),
                    onDeleted: () {
                      setState(() {
                        _goals.remove(g);
                        if (g.teamName == _teamAName && _scoreA > 0) _scoreA--;
                        if (g.teamName == _teamBName && _scoreB > 0) _scoreB--;
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Man of the Match (MOTM)
            AppTextField(
              label: 'رجل المباراة (Man of the Match ⭐)',
              hint: 'اسم اللاعب الأبرز...',
              controller: TextEditingController(text: _selectedMotmPlayerName),
              onChanged: (v) => _selectedMotmPlayerName = v.trim(),
            ),
            const SizedBox(height: 12),

            // Notes
            AppTextField(
              label: 'ملاحظات المباراة والتقرير الفني',
              hint: 'أجواء اللقاء، قرارات تحكيمية، ملخص الأداء...',
              controller: _notesController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Submit Button
            KickoffActionButton(
              label: 'اعتماد وتثبيت النتيجة رسمياً 🏆',
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamScoreControl({
    required String name,
    required Color color,
    required int score,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDarkElevated
            : AppColors.canvasLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded),
                onPressed: onDecrement,
              ),
              Text(
                '$score',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
