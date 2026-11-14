import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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

  /// Supported Arab & regional country dial codes (Yemen +967 default).
  static const List<({String code, String name, String flag})> countryCodes = [
    (code: '+967', name: 'اليمن', flag: '🇾🇪'),
    (code: '+966', name: 'السعودية', flag: '🇸🇦'),
    (code: '+971', name: 'الإمارات', flag: '🇦🇪'),
    (code: '+974', name: 'قطر', flag: '🇶🇦'),
    (code: '+965', name: 'الكويت', flag: '🇰🇼'),
    (code: '+973', name: 'البحرين', flag: '🇧🇭'),
    (code: '+968', name: 'عُمان', flag: '🇴🇲'),
    (code: '+20', name: 'مصر', flag: '🇪🇬'),
    (code: '+962', name: 'الأردن', flag: '🇯🇴'),
    (code: '+964', name: 'العراق', flag: '🇮🇶'),
    (code: '+961', name: 'لبنان', flag: '🇱🇧'),
    (code: '+249', name: 'السودان', flag: '🇸🇩'),
    (code: '+212', name: 'المغرب', flag: '🇲🇦'),
  ];

  /// Normalizes a picked contact phone number, extracts a matching supported
  /// country code (if present), and returns the local digits alongside the
  /// matched country code.
  static ({String countryCode, String localNumber}) parseContactPhone(
    String rawPhone, {
    String fallbackCountryCode = '+967',
  }) {
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();
    for (final ch in rawPhone.trim().split('')) {
      final arIdx = arabicDigits.indexOf(ch);
      if (arIdx != -1) {
        buffer.write(arIdx);
      } else {
        final faIdx = persianDigits.indexOf(ch);
        if (faIdx != -1) {
          buffer.write(faIdx);
        } else if (ch == '+' ||
            (ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57)) {
          buffer.write(ch);
        }
      }
    }

    var normalized = buffer.toString();
    if (normalized.startsWith('00')) {
      normalized = '+${normalized.substring(2)}';
    }

    final sortedCodes = countryCodes.map((c) => c.code).toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final code in sortedCodes) {
      final bareCode = code.substring(1);
      if (normalized.startsWith(code)) {
        final rest = normalized
            .substring(code.length)
            .replaceFirst(RegExp(r'^0+'), '');
        return (countryCode: code, localNumber: rest);
      }
      if (normalized.startsWith(bareCode) &&
          normalized.length > bareCode.length + 5) {
        final rest = normalized
            .substring(bareCode.length)
            .replaceFirst(RegExp(r'^0+'), '');
        return (countryCode: code, localNumber: rest);
      }
    }

    final local = normalized
        .replaceAll('+', '')
        .replaceFirst(RegExp(r'^0+'), '');
    return (countryCode: fallbackCountryCode, localNumber: local);
  }

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

  String _selectedCountryCode = '+967';
  PlayerPosition _selectedPosition = PlayerPosition.midfielder;
  PreferredFoot _selectedFoot = PreferredFoot.right;
  double _initialRating = 78.0;
  bool _isPickingContact = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickFromContacts() async {
    if (_isPickingContact) return;
    setState(() => _isPickingContact = true);

    try {
      var hasPerm = await FlutterContacts.permissions.has(PermissionType.read);
      if (!hasPerm) {
        final status = await FlutterContacts.permissions.request(
          PermissionType.read,
        );
        hasPerm =
            status == PermissionStatus.granted ||
            status == PermissionStatus.limited;

        if (!hasPerm) {
          if (!mounted) return;
          if (status == PermissionStatus.permanentlyDenied ||
              status == PermissionStatus.restricted) {
            context.showWarningToast(
              'يرجى تفعيل صلاحية جهات الاتصال من إعدادات التطبيق',
            );
            await FlutterContacts.permissions.openSettings();
          } else {
            context.showWarningToast(
              'يلزم السماح بالوصول إلى جهات الاتصال لاختيار رقم اللاعب',
            );
          }
          return;
        }
      }

      final contact = await FlutterContacts.native.showPicker(
        properties: {ContactProperty.name, ContactProperty.phone},
      );
      if (contact == null || !mounted) return;

      if (contact.phones.isEmpty) {
        context.showWarningToast(
          'جهة الاتصال المختارة لا تحتوي على رقم جوال مسجل',
        );
        return;
      }

      final selectedPhone = contact.phones.firstWhere(
        (p) => p.isPrimary == true,
        orElse: () => contact.phones.first,
      );
      final rawNumber = selectedPhone.normalizedNumber ?? selectedPhone.number;
      final parsed = AddPlayerDialog.parseContactPhone(
        rawNumber,
        fallbackCountryCode: _selectedCountryCode,
      );

      final contactName = (contact.displayName ?? '').trim();
      setState(() {
        _selectedCountryCode = parsed.countryCode;
        _phoneController.text = parsed.localNumber;
        if (_nameController.text.trim().isEmpty && contactName.isNotEmpty) {
          _nameController.text = contactName;
        }
      });

      if (contactName.isNotEmpty) {
        context.showSuccessToast('تم اختيار رقم $contactName من جهات الاتصال ✓');
      } else {
        context.showSuccessToast('تم تعبئة رقم الجوال من جهات الاتصال ✓');
      }
    } catch (_) {
      if (!mounted) return;
      context.showErrorToast('تعذر فتح دفتر جهات الاتصال على هذا الجهاز');
    } finally {
      if (mounted) {
        setState(() => _isPickingContact = false);
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final rawPhone = _phoneController.text.trim();
    final cleanLocal = rawPhone
        .replaceAll(RegExp(r'[\s\-\(\)]'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    final phone = cleanLocal.isEmpty
        ? ''
        : (cleanLocal.startsWith('+')
              ? cleanLocal
              : '$_selectedCountryCode$cleanLocal');
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
        goalkeeping: _selectedPosition == PlayerPosition.goalkeeper
            ? ratingInt
            : 50,
      ),
      createdAt: DateTime.now(),
    );

    context.read<PlayersBloc>().add(AddPlayerSubmitted(newPlayer));

    Navigator.of(context).pop();

    PlayerInviteShareSheet.show(context, player: newPlayer, phone: phone);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;

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
                  backgroundColor: isDark ? AppColors.darkText : AppColors.ink,
                  foregroundColor: isDark ? AppColors.ink : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _submit,
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_1_rounded, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'إضافة اللاعب للمجموعة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
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
              decoration: const InputDecoration(
                hintText: 'أدخل اسم اللاعب',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
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
              decoration: const InputDecoration(
                hintText: 'أدخل اللقب إن وجد',
                prefixIcon: Icon(Icons.tag_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 14),

            // Phone Number Field + Country Code Dropdown (Default: Yemen +967) + Contacts Picker
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                const Text(
                  'رقم الجوال (اختياري - لتوليد رابط الدعوة)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: _isPickingContact ? null : _pickFromContacts,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(
                        alpha: isDark ? 0.35 : 0.65,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isPickingContact)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary,
                            ),
                          )
                        else
                          Icon(
                            Icons.contacts_rounded,
                            size: 15,
                            color: cs.primary,
                          ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'اختيار من جهات الاتصال',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: _selectedCountryCode == '+967'
                            ? '77xxxxxxx'
                            : '5xxxxxxxx',
                        prefixIcon: const Icon(
                          Icons.phone_android_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 122,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCountryCode,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                      ),
                      selectedItemBuilder: (context) {
                        return AddPlayerDialog.countryCodes.map((c) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${c.flag} ${c.code}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList();
                      },
                      items: AddPlayerDialog.countryCodes.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.code,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                c.flag,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                c.code,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  c.name,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCountryCode = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Position Selection
            const Text(
              'المركز الأساسي في الملعب',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                final accent = cs.primary;
                final amber = AppColors.amber;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: PlayerPosition.values
                          .where((p) => p != PlayerPosition.goalkeeper)
                          .map((pos) {
                            final isSelected = _selectedPosition == pos;
                            return ChoiceChip(
                              label: Text(pos.labelArabic),
                              selected: isSelected,
                              selectedColor: accent,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : cs.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 12,
                              ),
                              backgroundColor: cs.surfaceContainer,
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : cs.outlineVariant.withValues(alpha: 0.7),
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setState(() => _selectedPosition = pos);
                                }
                              },
                            );
                          })
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // Preferred Foot
                    const Text(
                      'القدم المفضلة',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
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
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, size: 16, color: amber),
                              const SizedBox(width: 4),
                              Text(
                                '${_initialRating.round()}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
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
                      activeColor: accent,
                      inactiveColor: cs.surfaceContainerHighest,
                      label: '${_initialRating.round()}',
                      onChanged: (val) => setState(() => _initialRating = val),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFootOption(PreferredFoot foot, String label, bool isDark) {
    final isSelected = _selectedFoot == foot;
    final cs = Theme.of(context).colorScheme;
    final accent = cs.primary;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFoot = foot),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? accent : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : cs.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
