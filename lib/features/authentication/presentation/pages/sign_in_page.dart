import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.darkSlate,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  content: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.redText,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
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

                        // Logo emblem
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
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.sports_soccer_rounded,
                              size: 42,
                              color: isDark
                                  ? AppColors.turfGreenNeon
                                  : AppColors.turfGreenDark,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // App Title & Tagline
                        Text(
                          context.l10n.isArabic
                              ? 'تسجيل الدخول إلى Kickoff'
                              : 'Sign in to Kickoff',
                          textAlign: TextAlign.center,
                          style: context.textTheme.displayMedium?.copyWith(
                            fontSize: context.responsive(
                              standard: 24.0,
                              compact: 20.0,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.isArabic
                              ? 'إدارة وتنظيم مباريات كرة القدم الأسبوعية بذكاء'
                              : 'Intelligent football group & match management',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 36),

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

                        const SizedBox(height: 18),

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

                        const SizedBox(height: 32),

                        // Signature Action Button
                        KickoffActionButton(
                          label: context.l10n.isArabic
                              ? 'تسجيل الدخول'
                              : 'Sign In',
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),

                        const SizedBox(height: 24),

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
