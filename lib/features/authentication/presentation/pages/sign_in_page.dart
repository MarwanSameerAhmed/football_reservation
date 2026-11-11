import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../../core/utils/character_avatar_helper.dart';
import '../../../players/presentation/bloc/players_bloc.dart';
import '../../../players/presentation/bloc/players_event.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'marwan@kickoff.com');
  final _passwordController = TextEditingController(text: '123456');
  final _nameController = TextEditingController(text: 'سامي الجابر');
  final _phoneController = TextEditingController(text: '0555555555');
  final _customPhotoController = TextEditingController();

  bool _isSignUp = false;
  String _selectedAvatar = CharacterAvatarHelper.characterPresets.first['url']!;
  final List<Map<String, String>> _avatarPresets = CharacterAvatarHelper.characterPresets;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _customPhotoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isSignUp) {
        final photo = _customPhotoController.text.trim().isNotEmpty
            ? _customPhotoController.text.trim()
            : _selectedAvatar;

        context.read<AuthBloc>().add(
          AuthSignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          ),
        );

        // Also update player photo in players bloc
        final fakeId = 'p_${DateTime.now().millisecondsSinceEpoch}';
        context.read<PlayersBloc>().add(
          UpdatePlayerPhotoRequested(
            playerId: fakeId,
            photoUrl: photo,
          ),
        );
      } else {
        context.read<AuthBloc>().add(
          AuthSignInRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffResponsiveShell(
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go('/');
            } else if (state is AuthFailureState) {
              context.showErrorToast(state.errorMessage);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.horizontalPadding,
                    vertical: context.verticalPadding,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // Executive Formtor Logo Emblem
                        Center(
                          child: Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.darkSlate,
                                  Color(0xFF172720),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: AppColors.turfGreenNeon.withValues(
                                  alpha: 0.45,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryEmerald.withValues(
                                    alpha: isDark ? 0.25 : 0.16,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sports_soccer_rounded,
                              size: 40,
                              color: AppColors.owlLimeNeon,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // App Title & Tagline
                        Text(
                          _isSignUp
                              ? 'إنشاء حساب وتعيين كلمة المرور ⚽'
                              : (context.l10n.isArabic
                                  ? 'تسجيل الدخول إلى Kickoff'
                                  : 'Sign in to Kickoff'),
                          textAlign: TextAlign.center,
                          style: context.textTheme.displayMedium?.copyWith(
                            fontSize: context.responsive(
                              standard: 23.0,
                              compact: 19.0,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isSignUp
                              ? 'سجل بياناتك واختر صورتك الرمزية للمشاركة في المباريات والتصويت'
                              : (context.l10n.isArabic
                                  ? 'إدارة وتنظيم مباريات كرة القدم الأسبوعية بذكاء'
                                  : 'Intelligent football group & match management'),
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 28),

                        if (_isSignUp) ...[
                          // Full Name
                          AppTextField(
                            controller: _nameController,
                            label: 'اسم اللاعب الكامل',
                            hint: 'مثال: سامي الجابر',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'يرجى إدخال اسم اللاعب';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          AppTextField(
                            controller: _phoneController,
                            label: 'رقم الجوال',
                            hint: '05xxxxxxxx',
                            prefixIcon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'يرجى إدخال رقم الجوال';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email Field
                        AppTextField(
                          controller: _emailController,
                          label: context.l10n.isArabic
                              ? 'البريد الإلكتروني'
                              : 'Email Address',
                          hint: 'example@kickoff.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return context.l10n.isArabic
                                  ? 'يرجى إدخال البريد الإلكتروني'
                                  : 'Please enter your email';
                            }
                            if (!val.contains('@')) {
                              return context.l10n.isArabic
                                  ? 'صيغة البريد الإلكتروني غير صالحة'
                                  : 'Invalid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        AppPasswordField(
                          controller: _passwordController,
                          label: context.l10n.isArabic
                              ? 'كلمة المرور'
                              : 'Password',
                          hint: '••••••••',
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return context.l10n.isArabic
                                  ? 'يجب ألا تقل كلمة المرور عن 6 أحرف'
                                  : 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        if (_isSignUp) ...[
                          const SizedBox(height: 20),
                          // Optional Avatar / Photo Selection Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: context.colorScheme.outlineVariant,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.photo_camera_front_rounded,
                                      color: isDark
                                          ? AppColors.turfGreenNeon
                                          : AppColors.primaryEmerald,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'الصورة الرمزية للاعب (اختياري)',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.turfGreenNeon
                                            : AppColors.primaryEmerald,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _avatarPresets.map((preset) {
                                    final charUrl = preset['url']!;
                                    final title = preset['label']!;
                                    final isSelected =
                                        _selectedAvatar == charUrl &&
                                        _customPhotoController.text
                                            .trim()
                                            .isEmpty;
                                    final accent = isDark
                                        ? AppColors.turfGreenNeon
                                        : AppColors.primaryEmerald;

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedAvatar = charUrl;
                                          _customPhotoController.clear();
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? accent.withValues(
                                                  alpha: isDark ? 0.16 : 0.11,
                                                )
                                              : context
                                                  .colorScheme.surfaceContainer,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? accent
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            KickoffAvatar(
                                              photoUrl: charUrl,
                                              name: title,
                                              size: 26,
                                              borderWidth: 1,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _customPhotoController,
                                  decoration: const InputDecoration(
                                    labelText: 'أو رابط صورة مخصصة (URL)',
                                    hintText: 'https://...',
                                    prefixIcon: Icon(
                                      Icons.link_rounded,
                                      size: 18,
                                    ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Signature Action Button
                        KickoffActionButton(
                          label: _isSignUp
                              ? 'إنشاء الحساب وتعيين كلمة المرور 🚀'
                              : (context.l10n.isArabic
                                  ? 'تسجيل الدخول'
                                  : 'Sign In'),
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),

                        const SizedBox(height: 16),

                        // Toggle between Sign In & Sign Up
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                              });
                            },
                            child: Text(
                              _isSignUp
                                  ? 'لديك حساب مسجل بالفعل؟ تسجيل الدخول'
                                  : 'ليس لديك حساب؟ إنشاء حساب جديد وتعيين كلمة المرور ✍️',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.turfGreenNeon
                                    : AppColors.primaryEmerald,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Player Invite Activation Tile
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.turfGreenNeon
                                    : AppColors.primaryEmerald)
                                .withValues(alpha: isDark ? 0.12 : 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (isDark
                                      ? AppColors.turfGreenNeon
                                      : AppColors.primaryEmerald)
                                  .withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mark_email_read_rounded,
                                color: isDark
                                    ? AppColors.turfGreenNeon
                                    : AppColors.primaryEmerald,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'لديك دعوة من كابتن المجموعة؟',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/join'),
                                child: Text(
                                  'تفعيل فوري',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.turfGreenNeon
                                        : AppColors.primaryEmerald,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick demo role buttons
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                context.l10n.isArabic
                                    ? 'حسابات تجريبية سريعة:'
                                    : 'Quick Demo Accounts:',
                                style: context.textTheme.labelSmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.admin_panel_settings_rounded,
                                      size: 16,
                                    ),
                                    label: Text(
                                      context.l10n.isArabic
                                          ? 'مسؤول (Admin)'
                                          : 'Admin',
                                    ),
                                    onPressed: () {
                                      _emailController.text =
                                          'marwan@kickoff.com';
                                      _passwordController.text = '123456';
                                      _submit();
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.person_rounded,
                                      size: 16,
                                    ),
                                    label: Text(
                                      context.l10n.isArabic
                                          ? 'لاعب (Player)'
                                          : 'Player',
                                    ),
                                    onPressed: () {
                                      _emailController.text =
                                          'player@kickoff.com';
                                      _passwordController.text = '123456';
                                      _submit();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Link to Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.l10n.isArabic
                                  ? 'ليس لديك حساب؟'
                                  : "Don't have an account?",
                              style: context.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.push('/sign-up'),
                              child: Text(
                                context.l10n.isArabic
                                    ? 'إنشاء حساب جديد'
                                    : 'Sign Up',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
