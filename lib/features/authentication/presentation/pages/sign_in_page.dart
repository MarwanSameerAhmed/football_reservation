import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final rawLogin = _emailController.text.trim();
      final cleanPhone = rawLogin.replaceAll(RegExp(r'[\s\-]'), '');
      final loginEmail = rawLogin.contains('@')
          ? rawLogin
          : '${cleanPhone.replaceAll('+', '')}@kickoff.app';

      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: loginEmail,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _showInviteInputDialog(BuildContext context) {
    final codeController = TextEditingController();
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mark_email_read_rounded, color: cs.primary, size: 22),
            const SizedBox(width: 8),
            const Text(
              'تفعيل دعوة الانضمام',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إذا استلمت رابط دعوة من كابتن المجموعة عبر واتساب، الصق الرابط أو أدخل رمز التفعيل هنا للتحقق والبدء:',
              style: TextStyle(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'https://kickoff.app/join?... أو رمز الدعوة',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              elevation: 0,
            ),
            onPressed: () {
              final rawInput = codeController.text.trim();
              Navigator.of(dlgCtx).pop();
              if (rawInput.isEmpty) return;

              // Extract URL even if user pasted the entire WhatsApp invitation text
              final urlMatch = RegExp(
                r'(https?://\S+|kickoff://\S+)',
              ).firstMatch(rawInput);
              final extractedLink = urlMatch?.group(0) ?? rawInput;

              Uri? uri;
              try {
                uri = Uri.parse(extractedLink);
              } catch (_) {}

              final playerId =
                  uri?.queryParameters['id'] ??
                  uri?.queryParameters['token'] ??
                  extractedLink;
              final playerName = uri?.queryParameters['name'] ?? '';
              final playerPhone = uri?.queryParameters['phone'] ?? '';

              context.push(
                '/join',
                extra: {
                  'id': playerId,
                  'name': playerName,
                  'phone': playerPhone,
                },
              );
            },
            child: const Text('متابعة التفعيل'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;

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
                        const SizedBox(height: 16),

                        // Formtor Emblem & Brand Header
                        Center(
                          child: Container(
                            width: 92,
                            height: 92,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white,
                              border: Border.all(
                                color: cs.primary.withValues(
                                  alpha: isDark ? 0.55 : 0.25,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withValues(
                                    alpha: isDark ? 0.18 : 0.10,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(
                                'assets/App_icons/Formtor_Icon_1024.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Brand Pill
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withValues(
                                alpha: isDark ? 0.35 : 0.65,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: cs.primary.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              'Formtor',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // App Title & Tagline
                        Text(
                          context.l10n.isArabic ? 'تسجيل الدخول' : 'Sign In',
                          textAlign: TextAlign.center,
                          style: context.textTheme.displayMedium?.copyWith(
                            fontSize: context.responsive(
                              standard: 24.0,
                              compact: 21.0,
                            ),
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.isArabic
                              ? 'إدارة وتنظيم مباريات كرة القدم الأسبوعية'
                              : 'Intelligent football group & match management',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Email or Phone Field
                        AppTextField(
                          controller: _emailController,
                          label: context.l10n.isArabic
                              ? 'البريد الإلكتروني أو رقم الجوال'
                              : 'Email or Phone Number',
                          hint: context.l10n.isArabic
                              ? 'أدخل البريد الإلكتروني أو رقم الجوال'
                              : 'Enter email or phone number',
                          prefixIcon: Icons.account_circle_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return context.l10n.isArabic
                                  ? 'يرجى إدخال البريد الإلكتروني أو رقم الجوال'
                                  : 'Please enter email or phone number';
                            }
                            final clean = val.trim();
                            final isEmail = clean.contains('@');
                            final isPhone = RegExp(
                              r'^[0-9\+\s\-]{7,16}$',
                            ).hasMatch(clean);
                            if (!isEmail && !isPhone) {
                              return context.l10n.isArabic
                                  ? 'يرجى إدخال بريد إلكتروني صالح أو رقم جوال صحيح'
                                  : 'Please enter a valid email or phone number';
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

                        const SizedBox(height: 24),

                        // Signature Action Button
                        KickoffActionButton(
                          label: context.l10n.isArabic
                              ? 'تسجيل الدخول'
                              : 'Sign In',
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),

                        const SizedBox(height: 22),

                        // Player Invite Activation Banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(
                              alpha: isDark ? 0.25 : 0.45,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(
                                    alpha: isDark ? 0.22 : 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  Icons.mark_email_read_rounded,
                                  color: cs.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.isArabic
                                          ? 'وصلتك دعوة من الكابتن؟'
                                          : 'Received a captain invite?',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.l10n.isArabic
                                          ? 'فعّل حسابك عبر الرابط أو رمز الدعوة'
                                          : 'Activate via link or invite code',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.primary,
                                  foregroundColor: cs.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () =>
                                    _showInviteInputDialog(context),
                                child: Text(
                                  context.l10n.isArabic
                                      ? 'تفعيل فوري'
                                      : 'Activate',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
