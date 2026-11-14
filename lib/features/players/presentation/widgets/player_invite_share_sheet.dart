import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_bottom_sheet_shell.dart';
import '../../domain/entities/player_entity.dart';

/// Modal bottom sheet shown to the Captain immediately after adding a player,
/// generating a seamless invitation link and quick WhatsApp share text.
class PlayerInviteShareSheet extends StatelessWidget {
  final PlayerEntity player;
  final String phone;

  const PlayerInviteShareSheet({
    super.key,
    required this.player,
    required this.phone,
  });

  static Future<void> show(
    BuildContext context, {
    required PlayerEntity player,
    required String phone,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlayerInviteShareSheet(player: player, phone: phone),
    );
  }

  String get _inviteCode {
    final cleanId = player.id.replaceAll(RegExp(r'\D'), '');
    final suffix = cleanId.length >= 4
        ? cleanId.substring(cleanId.length - 4)
        : '7890';
    return 'KICK-$suffix';
  }

  String get _inviteLink {
    final encodedName = Uri.encodeComponent(player.name);
    final encodedPhone = Uri.encodeComponent(phone);
    return 'https://kickoff.app/join?id=${player.id}&name=$encodedName&phone=$encodedPhone';
  }

  String get _whatsAppMessage {
    return 'يا هلا ${player.name}! ⚽\n'
        'تمت إضافتك رسمياً في تطبيق مجموعة كيك أوف لمبارياتنا الأسبوعية.\n'
        'اضغط الرابط التالي لتفعيل حسابك والدخول المباشر بدون كلمة مرور:\n'
        '$_inviteLink\n\n'
        'رمز الدعوة السريع: $_inviteCode';
  }

  void _copyWhatsAppMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _whatsAppMessage));
    context.showSuccessToast(
      'تم نسخ رسالة الواتساب الجاهزة! الصقها في محادثة اللاعب 📲',
    );
  }

  void _copyLinkOnly(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _inviteLink));
    context.showSuccessToast('تم نسخ رابط التفعيل المباشر 🔗');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffBottomSheetShell(
      title: 'تمت إضافة ${player.name} 🎉',
      subtitle: 'توليد رابط الدعوة ورمز التفعيل المباشر',
      icon: Icons.mark_email_read_rounded,
      heightFactor: 0.78,
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 1,
              ),
              onPressed: () => _copyWhatsAppMessage(context),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'مشاركة رسالة الدعوة عبر واتساب 📲',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _copyLinkOnly(context),
              icon: const Icon(Icons.link_rounded, size: 18),
              label: const Text(
                'نسخ رابط التفعيل فقط 🔗',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'شارك رابط الدعوة أو رمز التفعيل مع صديقك ليفتح التطبيق بحسابه المعتمد وجلسة دائمة بدون الحاجة لكلمات مرور.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),

          // Invite Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  label: 'الاسم المعتمد',
                  value: player.name,
                  icon: Icons.person_rounded,
                  isDark: isDark,
                ),
                const Divider(height: 18),
                _buildInfoRow(
                  context,
                  label: 'رقم الجوال',
                  value: phone.isNotEmpty ? phone : 'غير مسجل',
                  icon: Icons.phone_android_rounded,
                  isDark: isDark,
                  forceLtrValue: phone.isNotEmpty,
                ),
                const Divider(height: 18),
                _buildInfoRow(
                  context,
                  label: 'رمز التفعيل السريع',
                  value: _inviteCode,
                  icon: Icons.vpn_key_rounded,
                  isDark: isDark,
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    bool isHighlighted = false,
    bool forceLtrValue = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final emerald = isDark ? AppColors.turfGreenNeon : AppColors.primaryEmerald;
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isHighlighted ? emerald : cs.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: cs.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          textDirection: forceLtrValue ? TextDirection.ltr : null,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? emerald : cs.onSurface,
          ),
        ),
      ],
    );
  }
}
