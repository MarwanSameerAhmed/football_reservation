import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/player_position.dart';
import '../../../../core/enums/preferred_foot.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_bottom_sheet_shell.dart';
import '../../../../core/utils/character_avatar_helper.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/player_skills.dart';
import '../bloc/players_bloc.dart';
import '../bloc/players_event.dart';
import 'player_invite_share_sheet.dart';

/// Modal dialog allowing the Captain/Admin to quickly add a new player to the squad.
class AddPlayerDialog extends StatefulWidget {
  const AddPlayerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PlayersBloc>(),
        child: const AddPlayerDialog(),
      ),
    );
  }

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();

  PlayerPosition _selectedPosition = PlayerPosition.midfielder;
  PreferredFoot _selectedFoot = PreferredFoot.right;
  double _initialRating = 78.0;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final phone = _phoneController.text.trim();
    final ratingInt = _initialRating.round();

    final newPlayer = PlayerEntity(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      nickname: nickname.isNotEmpty ? nickname : null,
      photoUrl: CharacterAvatarHelper.getCharacterUrl(name),
      primaryPosition: _selectedPosition,
      preferredFoot: _selectedFoot,
      skills: PlayerSkills(
        pace: ratingInt,
        shooting: ratingInt,
        passing: ratingInt,
        defending: ratingInt,
        physical: ratingInt,
        goalkeeping: _selectedPosition == PlayerPosition.goalkeeper ? ratingInt : 50,
      ),
      createdAt: DateTime.now(),
    );

    context.read<PlayersBloc>().add(AddPlayerSubmitted(newPlayer));

    Navigator.of(context).pop();

    PlayerInviteShareSheet.show(
      context,
      player: newPlayer,
      phone: phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffBottomSheetShell(
      title: 'إضافة لاعب جديد للمجموعة',
      subtitle: 'أدخل بيانات رفيقك لتسجيله وحساب إحصائياته',
      icon: Icons.person_add_rounded,
      heightFactor: 0.86,
      bottomAction: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF164E3D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'إضافة اللاعب للمجموعة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

              // Player Name
              const Text(
                'اسم اللاعب *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'مثال: سامي الجابر',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3D34)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3D34)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'الرجاء إدخال اسم اللاعب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Nickname Field (Full width, no jersey number)
              const Text(
                'اللقب الكروي (اختياري)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: 'مثال: الذئب / الهداف / المايسترو',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3D34)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3D34)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Phone Number Field
              const Text(
                'رقم الجوال (اختياري - لتوليد رابط الدعوة)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '05xxxxxxxx',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3D34)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3D34)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Position Selection
              const Text(
                'المركز الأساسي في الملعب',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: PlayerPosition.values.map((pos) {
                  final isSelected = _selectedPosition == pos;
                  return ChoiceChip(
                    label: Text(pos.labelArabic),
                    selected: isSelected,
                    selectedColor: const Color(0xFF164E3D),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF374151)),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF1F2823)
                        : const Color(0xFFF3F4F6),
                    onSelected: (val) {
                      if (val) setState(() => _selectedPosition = pos);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Preferred Foot
              const Text(
                'القدم المفضلة',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFootOption(PreferredFoot.right, 'اليمنى', isDark),
                  const SizedBox(width: 8),
                  _buildFootOption(PreferredFoot.left, 'اليسرى', isDark),
                  const SizedBox(width: 8),
                  _buildFootOption(PreferredFoot.both, 'كلتاهما', isDark),
                ],
              ),
              const SizedBox(height: 16),

              // Initial Skill Rating (Slider)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'التقييم المبدئي للمهارة',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF164E3D).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          '${_initialRating.round()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF164E3D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Slider(
                value: _initialRating,
                min: 60,
                max: 95,
                divisions: 35,
                activeColor: const Color(0xFF164E3D),
                inactiveColor: isDark
                    ? const Color(0xFF2E3D34)
                    : const Color(0xFFE5E7EB),
                label: '${_initialRating.round()}',
                onChanged: (val) => setState(() => _initialRating = val),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
    );
  }

  Widget _buildFootOption(PreferredFoot foot, String label, bool isDark) {
    final isSelected = _selectedFoot == foot;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFoot = foot),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF164E3D)
                : (isDark ? const Color(0xFF1F2823) : const Color(0xFFF3F4F6)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF164E3D)
                  : (isDark ? const Color(0xFF2E3D34) : const Color(0xFFE5E7EB)),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : const Color(0xFF374151)),
            ),
          ),
        ),
      ),
    );
  }
}

