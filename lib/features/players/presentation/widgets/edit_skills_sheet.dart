import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
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

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعديل تقييم المهارات',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.player.name,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.meadowTintDark
                        : AppColors.meadowTint,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currentSkills.starsRating} ★ (${currentSkills.overallScore}/100)',
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.turfGreenNeon
                              : AppColors.turfGreenDark,
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

            const SizedBox(height: 24),

            KickoffActionButton(
              label: 'حفظ التقييم الفني للمهارات',
              onPressed: _save,
            ),
          ],
        ),
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
                : AppColors.turfGreen,
            thumbColor: isDark ? AppColors.turfGreenNeon : AppColors.turfGreen,
            inactiveTrackColor: isDark
                ? AppColors.surfaceDarkElevated
                : AppColors.canvasLight,
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
