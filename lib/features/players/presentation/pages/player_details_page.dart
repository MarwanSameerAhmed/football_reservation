import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/widgets/kickoff_widgets.dart';
import '../../../../core/utils/avatar_image_helper.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../domain/entities/player_entity.dart';
import '../bloc/players_bloc.dart';
import '../bloc/players_event.dart';
import '../bloc/players_state.dart';
import '../widgets/edit_skills_sheet.dart';
import '../widgets/player_position_badge.dart';
import '../widgets/player_skills_breakdown.dart';

class PlayerDetailsPage extends StatelessWidget {
  final PlayerEntity initialPlayer;

  const PlayerDetailsPage({super.key, required this.initialPlayer});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return KickoffResponsiveShell(
      child: BlocBuilder<PlayersBloc, PlayersState>(
        builder: (context, state) {
          PlayerEntity player = initialPlayer;
          if (state is PlayersLoaded) {
            for (final p in state.allPlayers) {
              if (p.id == initialPlayer.id) {
                player = p;
                break;
              }
            }
          }

          final ovr = player.skills.overallRating;
          final authState = context.watch<AuthBloc>().state;
          final currentUser =
              authState is Authenticated ? authState.user : null;
          final canEditPhoto = currentUser != null &&
              (currentUser.id == player.userId ||
                  currentUser.id == player.id ||
                  (currentUser.displayName.trim().isNotEmpty &&
                      currentUser.displayName.trim() == player.name.trim()));

          final cs = context.colorScheme;
          return Scaffold(
            appBar: KickoffTopBar(
              title: player.nickname != null
                  ? '${player.name} (${player.nickname})'
                  : player.name,
            ),
            body: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 16.0,
              ),
              children: [
                // 1. Clean White Player Hero Card (tam_app surface)
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      // OVR Shield & Avatar Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // OVR Shield Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: cs.primary.withValues(alpha: 0.28),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$ovr',
                                  style: AppTypography.tabular(
                                    TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                                Text(
                                  'OVR تقييم',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Interactive Avatar (Editable ONLY by the player themselves)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              KickoffAvatar(
                                photoUrl: player.photoUrl,
                                name: player.name,
                                size: 78,
                                borderColor: cs.primary,
                                borderWidth: 2.5,
                                onTap: canEditPhoto
                                    ? () =>
                                        _showPhotoPickerSheet(context, player)
                                    : null,
                              ),
                              if (canEditPhoto)
                                Positioned(
                                  bottom: -2,
                                  left: context.isRtl ? -2 : null,
                                  right: context.isRtl ? null : -2,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _showPhotoPickerSheet(context, player),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: cs.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: cs.surface,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 13,
                                        color: cs.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        player.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      if (player.nickname != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          'لقب اللاعب: "${player.nickname}"',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Position Badges & Preferred Foot
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          PlayerPositionBadge(
                            position: player.primaryPosition,
                            showFullLabel: true,
                          ),
                          if (player.secondaryPosition != null)
                            PlayerPositionBadge(
                              position: player.secondaryPosition!,
                              showFullLabel: true,
                            ),
                          KickoffBadge(
                            label: 'القدم: ${player.preferredFoot.labelArabic}',
                            customBackground: cs.surfaceContainer,
                            customTextColor: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Last Updated Timestamp Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: cs.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 14,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'آخر تحديث: ${DateFormat('d MMMM yyyy', 'ar').format(player.createdAt)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 2. 4-Column Career Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'المباريات',
                        value: '${player.matchesPlayed}',
                        icon: Icons.stadium_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'الأهداف',
                        value: '${player.goals}',
                        icon: Icons.sports_soccer_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'الصناعة',
                        value: '${player.assists}',
                        icon: Icons.handshake_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'رجل المباراة',
                        value: '${player.motmCount}',
                        icon: Icons.military_tech_rounded,
                        isHighlight: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 3. Technical Skills Breakdown & Hexagon Ratings
                PlayerSkillsBreakdown(player: player),

                const SizedBox(height: 32),
              ],
            ),

            // Bottom Action Bar: Admin Can Edit Skills
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.horizontalPadding,
                  vertical: 12.0,
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final isAdmin =
                        authState is Authenticated &&
                        authState.user.role == UserRole.admin;

                    if (isAdmin) {
                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkText
                              : AppColors.ink,
                          foregroundColor: isDark
                              ? AppColors.ink
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          EditSkillsSheet.show(
                            context,
                            player: player,
                            userRole: UserRole.admin,
                          );
                        },
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text(
                          'تعديل المهارات والتقييم الفني (صلاحية الكابتن)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'تقييمات اللاعب معتمدة ومحدثة من قبل كابتن المجموعة.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    bool isHighlight = false,
  }) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final accent = isHighlight
        ? (isDark ? AppColors.amberNeon : AppColors.amber)
        : cs.primary;
    final iconWellBg = isHighlight
        ? (isDark
            ? AppColors.amber.withValues(alpha: 0.18)
            : AppColors.amberTint)
        : cs.primary.withValues(alpha: isDark ? 0.16 : 0.10);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: cs.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconWellBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: accent),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.tabular(
              context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: context.textTheme.bodySmall?.copyWith(fontSize: 10.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPhotoPickerSheet(BuildContext context, PlayerEntity player) {
    final cs = context.colorScheme;
    final accent = cs.primary;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: cs.outlineVariant, width: 1),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تغيير الصورة الرمزية للاعب 📸',
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'يتم حفظ الصورة كـ Base64 مجاناً في قاعدة البيانات بدون أي تكلفة تخزين',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: accent),
              title: const Text('اختيار من ألبوم الصور (Base64)'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final base64 = await AvatarImageHelper.pickAndEncodeImage(
                  source: ImageSource.gallery,
                );
                if (base64 != null && context.mounted) {
                  context.read<PlayersBloc>().add(
                    UpdatePlayerPhotoRequested(
                      playerId: player.id,
                      photoUrl: base64,
                    ),
                  );
                  context.showSuccessToast(
                    'تم تحديث صورة اللاعب وحفظها كـ Base64 بنجاح ✓',
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: accent),
              title: const Text('التقاط بالكاميرا'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final base64 = await AvatarImageHelper.pickAndEncodeImage(
                  source: ImageSource.camera,
                );
                if (base64 != null && context.mounted) {
                  context.read<PlayersBloc>().add(
                    UpdatePlayerPhotoRequested(
                      playerId: player.id,
                      photoUrl: base64,
                    ),
                  );
                  context.showSuccessToast(
                    'تم التقاط صورة اللاعب وتحديثها بنجاح ✓',
                  );
                }
              },
            ),
            if (player.photoUrl != null && player.photoUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.redText,
                ),
                title: const Text(
                  'حذف الصورة الحالية',
                  style: TextStyle(color: AppColors.redText),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.read<PlayersBloc>().add(
                    UpdatePlayerPhotoRequested(
                      playerId: player.id,
                      photoUrl: '',
                    ),
                  );
                  context.showSuccessToast('تمت استعادة الحرف الافتراضي');
                },
              ),
          ],
        ),
      ),
    );
  }
}
