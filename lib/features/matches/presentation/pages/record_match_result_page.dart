import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/poll_type.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_action_button.dart';
import '../../../../core/presentation/widgets/kickoff_avatar.dart';
import '../../../../core/presentation/widgets/kickoff_card.dart';
import '../../../../core/presentation/widgets/kickoff_responsive_shell.dart';
import '../../../../core/presentation/widgets/kickoff_top_bar.dart';
import '../../../players/presentation/bloc/players_bloc.dart';
import '../../../players/presentation/bloc/players_state.dart';
import '../../../polls/presentation/bloc/polls_bloc.dart';
import '../../../polls/presentation/bloc/polls_state.dart';
import '../../domain/entities/goal_event_entity.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_result_entity.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';

/// Dedicated Full Page for recording, validating, and officially cementing
/// the match results, 3-team round wins, scorers, assists, and MOTM voting outcomes.
class RecordMatchResultPage extends StatefulWidget {
  final MatchEntity match;

  const RecordMatchResultPage({super.key, required this.match});

  @override
  State<RecordMatchResultPage> createState() => _RecordMatchResultPageState();
}

class _RecordMatchResultPageState extends State<RecordMatchResultPage> {
  int _scoreA = 0; // Team A Wins
  int _scoreB = 0; // Team B Wins
  int _scoreC = 0; // Team C Wins

  final String _teamAName = 'الفريق الأول (الأخضر)';
  final String _teamBName = 'الفريق الثاني (الأبيض)';
  final String _teamCName = 'الفريق الثالث (الأسود)';

  String? _selectedMotmPlayerName;
  final TextEditingController _notesController = TextEditingController();

  final List<GoalEventEntity> _goals = [];

  // Goal Creation State
  String? _selectedScorerName;
  int _newGoalCount = 1;
  String _selectedGoalTeam = 'الفريق الأول (الأخضر)';
  String? _selectedAssistName;

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
    super.dispose();
  }

  static const String _noAssistOption = 'بدون صانع (مجهود فردي / ركلة جزاء)';

  List<String> _buildParticipantNames(BuildContext context) {
    final names = <String>{
      for (final p in widget.match.confirmedPlayers)
        if (p.playerName.trim().isNotEmpty) p.playerName.trim(),
    };

    try {
      final playersState = context.watch<PlayersBloc>().state;
      if (playersState is PlayersLoaded) {
        for (final player in playersState.allPlayers) {
          if (player.name.trim().isNotEmpty) {
            names.add(player.name.trim());
          }
        }
      }
    } catch (_) {
      // PlayersBloc may not be provided in isolated widget tests.
    }

    // Ensure any preselected MOTM / scorer / assist value exists in dropdown items
    // so DropdownButton assertions never fire when poll candidates differ from RSVPs.
    for (final selected in [
      _selectedMotmPlayerName,
      _selectedScorerName,
      _selectedAssistName,
    ]) {
      if (selected != null &&
          selected.trim().isNotEmpty &&
          selected != _noAssistOption) {
        names.add(selected.trim());
      }
    }

    return names.toList();
  }

  void _addGoals() {
    final scorer = _selectedScorerName;
    if (scorer == null || scorer.isEmpty) {
      context.showErrorToast('الرجاء اختيار اسم الهداف ⚽');
      return;
    }

    final assist = _selectedAssistName;
    final isNoneAssist = assist == null || assist == 'بدون صانع (مجهود فردي / ركلة جزاء)';

    setState(() {
      for (int i = 0; i < _newGoalCount; i++) {
        _goals.add(
          GoalEventEntity(
            id: 'goal_${DateTime.now().microsecondsSinceEpoch}_$i',
            scorerPlayerId: scorer.hashCode.toString(),
            scorerName: scorer,
            teamName: _selectedGoalTeam,
            assistPlayerName: isNoneAssist ? null : assist,
            minute: 10 + (_goals.length * 10),
          ),
        );
      }
      _selectedScorerName = null;
      _newGoalCount = 1;
      _selectedAssistName = null;
    });

    context.showSuccessToast('تم تسجيل الهدف بنجاح ⚽✓');
  }

  void _submit() {
    final finalResult = MatchResultEntity(
      id: widget.match.result?.id ?? 'res_${DateTime.now().millisecondsSinceEpoch}',
      matchId: widget.match.id,
      teamAName: _teamAName,
      teamBName: _teamBName,
      teamCName: _teamCName,
      teamAScore: _scoreA,
      teamBScore: _scoreB,
      teamCScore: _scoreC,
      manOfTheMatchName: _selectedMotmPlayerName ??
          (widget.match.confirmedPlayers.isNotEmpty
              ? widget.match.confirmedPlayers.first.playerName
              : null),
      goals: _goals,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      isLocked: true,
      recordedAt: DateTime.now(),
    );

    context.read<MatchesBloc>().add(RecordMatchResultRequested(finalResult));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final participantNames = _buildParticipantNames(context);

    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: const KickoffTopBar(
          title: 'تسجيل وتثبيت نتيجة اللقاء 🏆',
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: 16.0,
          ),
          children: [
            // Match Header Pill
            Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                final emerald = isDark
                    ? AppColors.turfGreenNeon
                    : AppColors.primaryEmerald;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: emerald.withValues(alpha: isDark ? 0.12 : 0.07),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: emerald.withValues(alpha: isDark ? 0.30 : 0.22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: emerald.withValues(alpha: isDark ? 0.18 : 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          Icons.sports_soccer_rounded,
                          color: emerald,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.match.title,
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'نظام 3 فرق (الرقم يمثل عدد الأشواط/المباريات الفائزة لكل فريق)',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Section 1: Team Round Wins (3 Teams)
            Text(
              '1. عدد مرات الفوز لكل فريق (الأشواط الفائزة) 🏆',
              style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTeamScoreCard(
                    context,
                    name: 'الأخضر 🟢',
                    color: isDark
                        ? AppColors.turfGreenNeon
                        : AppColors.primaryEmerald,
                    score: _scoreA,
                    isLeader: _scoreA > _scoreB && _scoreA > _scoreC && _scoreA > 0,
                    onIncrement: () => setState(() => _scoreA++),
                    onDecrement: () {
                      if (_scoreA > 0) setState(() => _scoreA--);
                    },
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTeamScoreCard(
                    context,
                    name: 'الأبيض ⚪',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    score: _scoreB,
                    isLeader: _scoreB > _scoreA && _scoreB > _scoreC && _scoreB > 0,
                    onIncrement: () => setState(() => _scoreB++),
                    onDecrement: () {
                      if (_scoreB > 0) setState(() => _scoreB--);
                    },
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTeamScoreCard(
                    context,
                    name: 'الأسود ⚫',
                    color: Theme.of(context).colorScheme.onSurface,
                    score: _scoreC,
                    isLeader: _scoreC > _scoreA && _scoreC > _scoreB && _scoreC > 0,
                    onIncrement: () => setState(() => _scoreC++),
                    onDecrement: () {
                      if (_scoreC > 0) setState(() => _scoreC--);
                    },
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 2: Man of the Match (Connected to Match Poll)
            Text(
              '2. رجل المباراة (Man of the Match ⭐)',
              style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'مرتبط باستطلاع رأي الحجز تلقائياً، أو اختر اللاعب الأبرز من التشكيلة:',
              style: TextStyle(
                fontSize: 11.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),

            // Check if there is an active MOTM poll for this match
            BlocBuilder<PollsBloc, PollsState>(
              builder: (context, pollsState) {
                if (pollsState is PollsLoaded) {
                  final motmPoll = pollsState.polls.where((p) {
                    return p.type == PollType.manOfTheMatch ||
                        (p.matchId != null && p.matchId == widget.match.id);
                  }).firstOrNull;

                  if (motmPoll != null && motmPoll.options.isNotEmpty) {
                    final sortedOptions = List.of(motmPoll.options)
                      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
                    final topOption = sortedOptions.first;
                    final amber =
                        isDark ? AppColors.amberNeon : AppColors.amberText;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: amber.withValues(alpha: isDark ? 0.14 : 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: amber.withValues(alpha: isDark ? 0.35 : 0.30),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.how_to_vote_rounded,
                            color: amber,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الفائز بتصويت رجل المباراة التابع للحجز 🗳️⭐',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${topOption.text} (${topOption.voteCount} صوت)',
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedMotmPlayerName = topOption.text;
                              });
                              context.showSuccessToast('تم اعتماد الفائز بالتصويت كرجل المباراة ⭐✓');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text('اعتماد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),

            // Dropdown Selector for MOTM
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.7),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: participantNames.contains(_selectedMotmPlayerName)
                      ? _selectedMotmPlayerName
                      : null,
                  hint: const Text('اختر رجل المباراة من قائمة المشاركين...'),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: participantNames.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Row(
                        children: [
                          KickoffAvatar(photoUrl: null, name: name, size: 28),
                          const SizedBox(width: 8),
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedMotmPlayerName = val),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Goals and Assists Recorder
            Text(
              '3. تسجيل الهدافين وصناع اللعب ⚽👟',
              style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'سجل اللاعب وكم هدف أحرز، وصانع الهدف (حتى لو كان من الفريق الآخر):',
              style: TextStyle(
                fontSize: 11.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),

            // Goal Input Card
            KickoffCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Scorer Selector
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: participantNames.contains(_selectedScorerName)
                              ? _selectedScorerName
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'الهداف ⚽ *',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          hint: const Text('اختر الهداف...'),
                          items: participantNames.map((name) {
                            return DropdownMenuItem(value: name, child: Text(name, style: const TextStyle(fontSize: 13)));
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedScorerName = v),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Goals Count Counter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                if (_newGoalCount > 1) setState(() => _newGoalCount--);
                              },
                              child: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '$_newGoalCount',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() => _newGoalCount++),
                              child: Icon(
                                Icons.add_circle_outline_rounded,
                                size: 20,
                                color: isDark
                                    ? AppColors.turfGreenNeon
                                    : AppColors.primaryEmerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Assist Selector (Allows anyone including opponents)
                  DropdownButtonFormField<String>(
                    value: (_selectedAssistName == _noAssistOption ||
                            participantNames.contains(_selectedAssistName))
                        ? _selectedAssistName
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'صانع الهدف (الأسيست) 👟 (اختياري)',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    hint: const Text('بدون صانع (مجهود فردي / ركلة جزاء)...'),
                    items: [
                      const DropdownMenuItem(
                        value: _noAssistOption,
                        child: Text(_noAssistOption, style: TextStyle(fontSize: 12)),
                      ),
                      ...participantNames.map((name) {
                        return DropdownMenuItem(
                          value: name,
                          child: Text('$name (صانع هدف)', style: const TextStyle(fontSize: 13)),
                        );
                      }),
                    ],
                    onChanged: (v) => setState(() => _selectedAssistName = v),
                  ),
                  const SizedBox(height: 10),

                  // Team selector for the goal
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGoalTeam,
                          decoration: const InputDecoration(
                            labelText: 'فريق الهداف',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: [_teamAName, _teamBName, _teamCName].map((t) {
                            return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedGoalTeam = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addGoals,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.turfGreenNeon
                              : AppColors.primaryEmerald,
                          foregroundColor:
                              isDark ? AppColors.canvasDark : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('إضافة ⚽', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Goals Summary List
            if (_goals.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _goals.map((g) {
                  final assistText = g.assistPlayerName != null ? ' (صناعة: ${g.assistPlayerName})' : '';
                  final cs = Theme.of(context).colorScheme;
                  return Chip(
                    backgroundColor: cs.surfaceContainer,
                    side: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.7),
                    ),
                    avatar: const Text('⚽', style: TextStyle(fontSize: 14)),
                    label: Text('${g.scorerName}$assistText', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    deleteIcon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark ? AppColors.redNeon : AppColors.redText,
                    ),
                    onDeleted: () {
                      setState(() => _goals.remove(g));
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Section 4: Technical Notes
            Text(
              '4. ملاحظات وتقرير المباراة الفني (اختياري)',
              style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'أجواء اللقاء، قرارات تحكيمية، ملخص الأداء...',
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 12),
            child: KickoffActionButton(
              label: 'اسحب لتثبيت النتيجة رسمياً وإشعار المجموعة 🏆',
              onPressed: _submit,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScoreCard(
    BuildContext context, {
    required String name,
    required Color color,
    required int score,
    required bool isLeader,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required bool isDark,
  }) {
    final cs = Theme.of(context).colorScheme;
    final emerald = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLeader
              ? emerald
              : cs.outlineVariant.withValues(alpha: 0.7),
          width: isLeader ? 2.0 : 1.0,
        ),
        boxShadow: isLeader
            ? [
                BoxShadow(
                  color: emerald.withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isLeader)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: emerald.withValues(alpha: isDark ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'بطل اليوم 🏆',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: emerald,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(
            'فوز',
            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: onDecrement,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.remove_circle_outline_rounded, size: 20),
                ),
              ),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 20,
                    color: emerald,
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
