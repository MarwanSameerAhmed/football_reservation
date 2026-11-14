import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.player;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          displayName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: _phoneController.text.isNotEmpty
              ? _phoneController.text
              : null,
          role: _selectedRole,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: KickoffTopBar(
          title: context.l10n.isArabic ? 'إنشاء حساب جديد' : 'Create Account',
        ),
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

            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.horizontalPadding,
                  vertical: 16.0,
                ),
                children: [
                  Text(
                    context.l10n.isArabic
                        ? 'انضم إلى مجموعة كرة القدم الخاصة بك'
                        : 'Join your weekly football group',
                    style: context.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  // Display Name
                  AppTextField(
                    controller: _nameController,
                    label: context.l10n.isArabic ? 'الاسم الكامل' : 'Full Name',
                    hint: context.l10n.isArabic
                        ? 'أدخل الاسم الكامل'
                        : 'Enter full name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return context.l10n.isArabic
                            ? 'يرجى إدخال اسمك'
                            : 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email
                  AppTextField(
                    controller: _emailController,
                    label: context.l10n.isArabic
                        ? 'البريد الإلكتروني'
                        : 'Email Address',
                    hint: context.l10n.isArabic
                        ? 'أدخل البريد الإلكتروني'
                        : 'Enter email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return context.l10n.isArabic
                            ? 'يرجى إدخال البريد الإلكتروني'
                            : 'Please enter email';
                      }
                      if (!val.contains('@')) {
                        return context.l10n.isArabic
                            ? 'صيغة البريد الإلكتروني غير صالحة'
                            : 'Invalid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Phone Number
                  AppTextField(
                    controller: _phoneController,
                    label: context.l10n.isArabic
                        ? 'رقم الهاتف (اختياري)'
                        : 'Phone Number (Optional)',
                    hint: context.l10n.isArabic
                        ? 'أدخل رقم الهاتف'
                        : 'Enter phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  // Password
                  AppPasswordField(
                    controller: _passwordController,
                    label: context.l10n.isArabic ? 'كلمة المرور' : 'Password',
                    hint: context.l10n.isArabic
                        ? 'أدخل كلمة المرور'
                        : 'Enter password',
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return context.l10n.isArabic
                            ? 'يجب ألا تقل كلمة المرور عن 6 أحرف'
                            : 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Role Selection
                  Text(
                    context.l10n.isArabic
                        ? 'نوع العضوية في المجموعة:'
                        : 'Membership Role:',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: KickoffChoiceChip(
                          label: context.l10n.isArabic
                              ? 'لاعب (Player)'
                              : 'Player',
                          isSelected: _selectedRole == UserRole.player,
                          onTap: () =>
                              setState(() => _selectedRole = UserRole.player),
                          icon: Icons.sports_soccer_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KickoffChoiceChip(
                          label: context.l10n.isArabic
                              ? 'مسؤول (Admin)'
                              : 'Admin',
                          isSelected: _selectedRole == UserRole.admin,
                          onTap: () =>
                              setState(() => _selectedRole = UserRole.admin),
                          icon: Icons.admin_panel_settings_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Signature Action Button
                  KickoffActionButton(
                    label: context.l10n.isArabic
                        ? 'إتمام التسجيل والبدء'
                        : 'Complete Registration',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
