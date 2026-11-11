import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_avatar.dart';
import '../../../../core/presentation/widgets/kickoff_responsive_shell.dart';
import '../../../../core/utils/avatar_image_helper.dart';
import '../../../players/presentation/bloc/players_bloc.dart';
import '../../../players/presentation/bloc/players_event.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Screen displayed when a player opens an invitation link from the Admin/Captain.
/// Name and phone number are locked (read-only) and pre-filled.
/// Upon confirmation, the session is stored permanently on the device.
class PlayerActivationPage extends StatefulWidget {
  final String playerId;
  final String name;
  final String phone;
  final String role;

  const PlayerActivationPage({
    super.key,
    required this.playerId,
    required this.name,
    required this.phone,
    this.role = 'player',
  });

  @override
  State<PlayerActivationPage> createState() => _PlayerActivationPageState();
}

class _PlayerActivationPageState extends State<PlayerActivationPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _customPhotoController = TextEditingController();

  String _selectedAvatar = '⚽';
  final List<Map<String, String>> _avatarPresets = const [
    {'emoji': '⚽', 'title': 'كلاسيك'},
    {'emoji': '🦁', 'title': 'الأسد'},
    {'emoji': '⚡', 'title': 'الصاروخ'},
    {'emoji': '🦅', 'title': 'الصقر'},
    {'emoji': '🎯', 'title': 'القناص'},
    {'emoji': '🔥', 'title': 'الحاسم'},
    {'emoji': '🧤', 'title': 'الأمين'},
    {'emoji': '👑', 'title': 'المايسترو'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.name.isNotEmpty ? widget.name : 'لاعب المجموعة',
    );
    _phoneController = TextEditingController(
      text: widget.phone.isNotEmpty ? widget.phone : '0500000000',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _customPhotoController.dispose();
    super.dispose();
  }

  void _activate() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final photo = _customPhotoController.text.trim().isNotEmpty
        ? _customPhotoController.text.trim()
        : _selectedAvatar;

    context.read<AuthBloc>().add(
      AuthActivatePlayerRequested(
        id: widget.playerId,
        displayName: name,
        phoneNumber: phone,
        photoUrl: photo,
      ),
    );

    context.read<PlayersBloc>().add(
      UpdatePlayerPhotoRequested(playerId: widget.playerId, photoUrl: photo),
    );

    context.go('/');

    context.showSuccessToast(
      'أهلاً بك يا $name! تم تفعيل حسابك وحفظ جلستك للأبد ⚽✓',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffResponsiveShell(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Emblem
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.meadowTintDark
                            : AppColors.meadowTint,
                        border: Border.all(
                          color: isDark
                              ? AppColors.turfGreenNeon
                              : AppColors.turfGreen,
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.sports_soccer_rounded,
                        size: 42,
                        color: Color(0xFF164E3D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Headline
                  Text(
                    'تفعيل حساب لاعب جديد ⚽',
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'تمت دعوتك رسمياً بواسطة كابتن المجموعة للمشاركة في المباريات الأسبوعية والتصويت',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Verified Player Card Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161C19) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF26332B)
                            : const Color(0xFFE2E8E4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.05,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: Color(0xFF164E3D),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'بيانات العضوية المعتمدة (غير قابلة للتعديل)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFF164E3D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Player Name Field (Locked)
                        TextFormField(
                          controller: _nameController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'اسم اللاعب',
                            prefixIcon: const Icon(Icons.person_rounded),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF164E3D,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.lock_rounded,
                                          size: 14,
                                          color: Color(0xFF164E3D),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'معتمد',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF164E3D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1C2420)
                                : const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Phone Number Field (Locked)
                        TextFormField(
                          controller: _phoneController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'رقم الجوال',
                            prefixIcon: const Icon(Icons.phone_android_rounded),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF164E3D,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.lock_rounded,
                                          size: 14,
                                          color: Color(0xFF164E3D),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'معتمد',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF164E3D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1C2420)
                                : const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Optional Password Setup
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'تعيين كلمة مرور لحسابك (اختياري)',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            helperText:
                                'لتسجيل الدخول السريع مستقبلاً من أي جهاز أو متصفح',
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1C2420)
                                : const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Optional Avatar / Photo Selection Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161C19) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF26332B)
                            : const Color(0xFFE2E8E4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.05,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.photo_camera_front_rounded,
                              color: Color(0xFF164E3D),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الصورة الشخصية للاعب (اختياري)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFF164E3D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ارفع صورتك مباشرة (يتم حفظها مجاناً كـ Base64 في قاعدة البيانات دون أي تكلفة تخزين)، أو اختر أيقونة رياضية تعبر عنك:',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Live Avatar Preview & Direct Upload Actions
                        Center(
                          child: Column(
                            children: [
                              KickoffAvatar(
                                photoUrl: _customPhotoController.text.trim().isNotEmpty
                                    ? _customPhotoController.text.trim()
                                    : _selectedAvatar,
                                name: _nameController.text,
                                size: 80,
                                borderWidth: 2.5,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final base64Image =
                                          await AvatarImageHelper.pickAndEncodeImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (base64Image != null) {
                                        setState(() {
                                          _customPhotoController.text = base64Image;
                                        });
                                        if (context.mounted) {
                                          context.showSuccessToast(
                                            'تم اختيار وضغط صورتك بنجاح كـ Base64 📸✓',
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF22382C)
                                          : const Color(0xFFEAF5EF),
                                      foregroundColor: isDark
                                          ? const Color(0xFF86EFAC)
                                          : const Color(0xFF164E3D),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: isDark
                                              ? const Color(0xFF335240)
                                              : const Color(0xFFC7E2D2),
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(Icons.photo_library_rounded, size: 17),
                                    label: const Text(
                                      'المعرض',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final base64Image =
                                          await AvatarImageHelper.pickAndEncodeImage(
                                        source: ImageSource.camera,
                                      );
                                      if (base64Image != null) {
                                        setState(() {
                                          _customPhotoController.text = base64Image;
                                        });
                                        if (context.mounted) {
                                          context.showSuccessToast(
                                            'تم التقاط صورتك بنجاح كـ Base64 📸✓',
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF22382C)
                                          : const Color(0xFFEAF5EF),
                                      foregroundColor: isDark
                                          ? const Color(0xFF86EFAC)
                                          : const Color(0xFF164E3D),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: isDark
                                              ? const Color(0xFF335240)
                                              : const Color(0xFFC7E2D2),
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(Icons.camera_alt_rounded, size: 17),
                                    label: const Text(
                                      'الكاميرا',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (_customPhotoController.text.trim().isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: AppColors.redText),
                                      tooltip: 'إزالة الصورة',
                                      onPressed: () {
                                        setState(() {
                                          _customPhotoController.clear();
                                        });
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          'أو اختر أيقونة جاهزة:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // Presets Grid
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _avatarPresets.map((preset) {
                            final emoji = preset['emoji']!;
                            final title = preset['title']!;
                            final isSelected =
                                _selectedAvatar == emoji &&
                                _customPhotoController.text.trim().isEmpty;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedAvatar = emoji;
                                  _customPhotoController.clear();
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                            ? const Color(0xFF22382C)
                                            : const Color(0xFFEAF5EF))
                                      : (isDark
                                            ? const Color(0xFF1D2622)
                                            : const Color(0xFFF4F6F5)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF164E3D)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? (isDark
                                                  ? const Color(0xFF86EFAC)
                                                  : const Color(0xFF164E3D))
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Base64 / URL info note
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF19231D)
                                : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF263D2F)
                                  : const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.savings_rounded, color: Color(0xFF164E3D), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ميزة التوفير: يتم ضغط وحفظ صورتك بصيغة Base64 مباشرة بدون أي اشتراك مدفوع في الفايربيس.',
                                  style: TextStyle(fontSize: 11, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Permanent Session Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1B241E)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E3D34)
                            : const Color(0xFFBBF7D0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.devices_rounded,
                          color: Color(0xFF164E3D),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'حفظ الجلسة بشكل دائم على هذا الجهاز',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'لن تحتاج لإدخال كلمة مرور أو تسجيل الدخول مستقبلاً، وسيتم ربط حضورك وتصويتاتك بحسابك المعتمد فوراً.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Activation Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.turfGreenNeon
                            : AppColors.turfGreen,
                        foregroundColor: isDark
                            ? AppColors.darkSlate
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _activate,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'تأكيد الدخول والتفعيل',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
