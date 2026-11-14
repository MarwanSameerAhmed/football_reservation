import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/poll_type.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/kickoff_action_button.dart';
import '../../../../core/presentation/widgets/kickoff_bottom_sheet_shell.dart';
import '../../../polls/domain/entities/poll_entity.dart';
import '../../../polls/domain/entities/poll_option_entity.dart';
import '../../../polls/presentation/bloc/polls_bloc.dart';
import '../../../polls/presentation/bloc/polls_event.dart';
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
    final pollsBloc = context.read<PollsBloc>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: pollsBloc,
        child: RecordResultSheet(match: match, onSaveResult: onSaveResult),
      ),
    );
  }

  @override
  State<RecordResultSheet> createState() => _RecordResultSheetState();
}

class _RecordResultSheetState extends State<RecordResultSheet> {
  int _scoreA = 0;
  int _scoreB = 0;
  int _scoreC = 0;
  final String _teamAName = 'الفريق الأول (الأخضر)';
  final String _teamBName = 'الفريق الثاني (الأبيض)';
  final String _teamCName = 'الفريق الثالث (الأسود)';
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
      _scoreC = existing.teamCScore ?? 0;
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
      } else if (_goalTeam == _teamBName) {
        _scoreB++;
      } else {
        _scoreC++;
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
      teamCScore: _scoreC,
      teamAName: _teamAName,
      teamBName: _teamBName,
      teamCName: _teamCName,
      goals: _goals,
      manOfTheMatchName: _selectedMotmPlayerName,
      isLocked: true,
      recordedAt: DateTime.now(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    widget.onSaveResult(result);

    // Automatically update and unlock the MOTM poll with all confirmed match players
    if (widget.match.confirmedPlayers.isNotEmpty) {
      final options = widget.match.confirmedPlayers.map((p) {
        return PollOptionEntity(
          id: p.playerId,
          text: p.playerName,
          subtitle: p.playerPosition.labelArabic,
          voterUserIds: const [],
        );
      }).toList();

      final motmPoll = PollEntity(
        id: 'poll_motm_${widget.match.id}',
        matchId: widget.match.id,
        matchDetails: '${widget.match.title} • ${widget.match.pitchName}',
        title: 'رجل المباراة 🌟 (${widget.match.title})',
        description: 'اختر اللاعب الأفضل في اللقاء من بين جميع المشاركين',
        type: PollType.manOfTheMatch,
        options: options,
        creatorId: 'admin_1',
        allowMultipleVotes: false,
        closesAt: DateTime.now().add(const Duration(days: 2)),
        isClosed: false,
        isLockedUntilMatchEnds: false,
        createdAt: DateTime.now(),
      );
      context.read<PollsBloc>().add(CreatePollRequested(motmPoll));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final accent = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;

    return KickoffBottomSheetShell(
      title: 'تسجيل وتثبيت نتيجة المباراة الرسمية',
      subtitle:
          'نظام 3 فرق • رصد الأهداف وصناع اللعب وتفعيل استطلاع رجل المباراة',
      icon: Icons.emoji_events_rounded,
      heightFactor: 0.88,
      bottomAction: KickoffActionButton(
        label: 'اعتماد وتثبيت النتيجة رسمياً 🏆',
        onPressed: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Purpose Explanation Banner
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accent.withValues(alpha: 0.28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 17,
                      color: accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ما فائدة هذه الصفحة وكيف تعمل؟',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '١. اعتماد أهداف ونتائج الفرق الثلاثة (الأخضر، الأبيض، الأسود) رسمياً.\n'
                  '٢. رصد أهداف وصناع اللعب لتحديث صدارة الهدافين وصناع اللعب تلقائياً.\n'
                  '٣. فك قفل استطلاع (رجل المباراة) فور الحفظ لإتاحة التصويت لجميع المشاركين.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3-Team Score Steppers
          Row(
            children: [
              // Team A (Green)
              Expanded(
                child: _buildTeamScoreControl(
                  name: 'الأخضر',
                  color: accent,
                  score: _scoreA,
                  onIncrement: () => setState(() => _scoreA++),
                  onDecrement: () => setState(() {
                    if (_scoreA > 0) _scoreA--;
                  }),
                ),
              ),
              const SizedBox(width: 6),
              // Team B (White)
              Expanded(
                child: _buildTeamScoreControl(
                  name: 'الأبيض',
                  color: cs.onSurfaceVariant,
                  score: _scoreB,
                  onIncrement: () => setState(() => _scoreB++),
                  onDecrement: () => setState(() {
                    if (_scoreB > 0) _scoreB--;
                  }),
                ),
              ),
              const SizedBox(width: 6),
              // Team C (Black)
              Expanded(
                child: _buildTeamScoreControl(
                  name: 'الأسود',
                  color: isDark ? Colors.white : Colors.black87,
                  score: _scoreC,
                  onIncrement: () => setState(() => _scoreC++),
                  onDecrement: () => setState(() {
                    if (_scoreC > 0) _scoreC--;
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
              // Team Choice (3 Teams)
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _goalTeam,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: [_teamAName, _teamBName, _teamCName].map((t) {
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
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
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
                      if (g.teamName == _teamCName && _scoreC > 0) _scoreC--;
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
          const SizedBox(height: 12),
        ],
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: onDecrement,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 22,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              Text(
                '$score',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 22,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
