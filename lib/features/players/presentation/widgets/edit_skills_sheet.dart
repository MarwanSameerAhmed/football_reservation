import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_bottom_sheet_shell.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/player_skills.dart';
import '../bloc/players_bloc.dart';
import '../bloc/players_event.dart';

class EditSkillsSheet extends StatefulWidget {
  final PlayerEntity player;
  final UserRole userRole;

  const EditSkillsSheet({
    super.key,
    required this.player,
    required this.userRole,
  });

  static Future<void> show(
    BuildContext context, {
    required PlayerEntity player,
    required UserRole userRole,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PlayersBloc>(),
        child: EditSkillsSheet(player: player, userRole: userRole),
      ),
    );
  }

  @override
  State<EditSkillsSheet> createState() => _EditSkillsSheetState();
}

class _EditSkillsSheetState extends State<EditSkillsSheet> {
  late double _pace;
  late double _shooting;
  late double _passing;
  late double _defending;
  late double _physical;
  late double _goalkeeping;

  @override
  void initState() {
    super.initState();
    final skills = widget.player.skills;
    _pace = skills.pace.toDouble();
    _shooting = skills.shooting.toDouble();
    _passing = skills.passing.toDouble();
    _defending = skills.defending.toDouble();
    _physical = skills.physical.toDouble();
    _goalkeeping = skills.goalkeeping.toDouble();
  }

  PlayerSkills _computeCurrentSkills() {
    return PlayerSkills(
      pace: _pace.round(),
      shooting: _shooting.round(),
      passing: _passing.round(),
      defending: _defending.round(),
      physical: _physical.round(),
      goalkeeping: _goalkeeping.round(),
    );
  }

  void _save() {
    final updatedSkills = _computeCurrentSkills();
    context.read<PlayersBloc>().add(
      UpdatePlayerSkillsSubmitted(
        playerId: widget.player.id,
        skills: updatedSkills,
        updaterRole: widget.userRole,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final currentSkills = _computeCurrentSkills();

    return KickoffBottomSheetShell(
      title: 'تعديل تقييم المهارات',
      subtitle: widget.player.name,
      icon: Icons.tune_rounded,
      heightFactor: 0.82,
      bottomAction: KickoffActionButton(
        label: 'حفظ التقييم الفني للمهارات',
        onPressed: _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المستوى الإجمالي الحالي',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColors.turfGreenNeon
                            : AppColors.primaryEmerald)
                        .withValues(alpha: isDark ? 0.16 : 0.10),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                    border: Border.all(
                      color: (isDark
                              ? AppColors.turfGreenNeon
                              : AppColors.primaryEmerald)
                          .withValues(alpha: isDark ? 0.30 : 0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.amberText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currentSkills.starsRating} ★ (${currentSkills.overallScore}/100)',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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

            const SizedBox(height: 20),

            _buildSlider(
              'السرعة (PAC)',
              _pace,
              (v) => setState(() => _pace = v),
            ),
            _buildSlider(
              'التسديد (SHO)',
              _shooting,
              (v) => setState(() => _shooting = v),
            ),
            _buildSlider(
              'التمرير (PAS)',
              _passing,
              (v) => setState(() => _passing = v),
            ),
            _buildSlider(
              'الدفاع (DEF)',
              _defending,
              (v) => setState(() => _defending = v),
            ),
            _buildSlider(
              'اللياقة والبدن (PHY)',
              _physical,
              (v) => setState(() => _physical = v),
            ),
            if (widget.player.primaryPosition == PlayerPosition.goalkeeper)
              _buildSlider(
                'الحراسة (GK)',
                _goalkeeping,
                (v) => setState(() => _goalkeeping = v),
              ),

            const SizedBox(height: 12),
          ],
        ),
      );
  }

  Widget _buildSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    final isDark = context.isDarkMode;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('${value.round()}', style: context.textTheme.labelMedium),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: isDark
                ? AppColors.turfGreenNeon
                : AppColors.primaryEmerald,
            thumbColor: isDark
                ? AppColors.turfGreenNeon
                : AppColors.primaryEmerald,
            inactiveTrackColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Slider(
            value: value,
            min: 30,
            max: 99,
            divisions: 69,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
