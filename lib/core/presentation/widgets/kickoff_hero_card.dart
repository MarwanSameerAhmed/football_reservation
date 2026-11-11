import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../extensions/context_extensions.dart';
import '../../motion/kickoff_motion.dart';

/// Executive Obsidian Matchday Hero Card matching the Formtor identity.
///
/// Features:
/// - Signature dark obsidian pitch backdrop with subtle emerald/lime glow.
/// - Frosted glass inner summary panel for stadium, date, time, and attendance.
/// - Tabular figures (`FontFeature.tabularFigures`) for aligned player counts.
/// - Tactile micro-scale (`KickoffPressable`) and single 1-tap RSVP CTA.
class KickoffHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? matchTitle;
  final String? matchDate;
  final String? matchTime;
  final int confirmedPlayers;
  final int maxPlayers;
  final int waitingCount;
  final String? rating;
  final String? fee;
  final String? distanceOrDate;
  final String? imageUrl;
  final bool isUserRegistered;
  final bool isRegistrationOpen;
  final DateTime? registrationOpensAt;
  final VoidCallback? onTap;
  final VoidCallback? onRsvpTap;

  const KickoffHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.matchTitle,
    this.matchDate,
    this.matchTime,
    this.confirmedPlayers = 14,
    this.maxPlayers = 18,
    this.waitingCount = 0,
    this.rating,
    this.fee,
    this.distanceOrDate,
    this.imageUrl,
    this.isUserRegistered = false,
    this.isRegistrationOpen = true,
    this.registrationOpensAt,
    this.onTap,
    this.onRsvpTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final displayMatchTitle = matchTitle ?? 'مباراة الجمعة الكبرى';
    final displayDate = matchDate ?? 'الجمعة 14 نوفمبر';
    final displayTime = matchTime ?? '08:30 م';
    final totalSeats = maxPlayers > 0 ? maxPlayers : 18;
    final remaining = (totalSeats - confirmedPlayers).clamp(0, totalSeats);
    final isFull = confirmedPlayers >= totalSeats;
    final double fillPercentage = (confirmedPlayers / totalSeats).clamp(
      0.0,
      1.0,
    );

    final statusColor = !isRegistrationOpen
        ? AppColors.blueNeon
        : isFull
            ? AppColors.redNeon
            : AppColors.turfGreenNeon;

    return Semantics(
      button: onTap != null,
      label: '$displayMatchTitle, $title, $subtitle',
      child: KickoffPressable(
        enabled: onTap != null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(26),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                            Color(0xFF0E1713),
                            Color(0xFF111D18),
                            Color(0xFF0A120E),
                          ]
                        : const [
                            Color(0xFF111815),
                            Color(0xFF15251E),
                            Color(0xFF0E1A15),
                          ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : const Color(0xFF23372E),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : AppColors.darkSlate)
                          .withValues(alpha: isDark ? 0.45 : 0.16),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Subtle ambient Formtor pitch glow top-left
                    Positioned(
                      top: -40,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.turfGreen.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Subtle pitch corner emblem bottom-right
                    Positioned(
                      bottom: -24,
                      right: -24,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.turfGreenNeon
                                .withValues(alpha: 0.08),
                            width: 18,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Pill Row
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              // Matchday Executive Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sports_soccer_rounded,
                                      size: 13,
                                      color: AppColors.owlLimeNeon,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'المباراة القادمة',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Availability Glow Status Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.45),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      !isRegistrationOpen &&
                                              registrationOpensAt != null
                                          ? 'يفتح الحجز ${DateFormat('hh:mm a', 'ar').format(registrationOpensAt!)}'
                                          : isFull
                                              ? 'قائمة انتظار'
                                              : (remaining <= 3
                                                    ? 'متبقي $remaining مقاعد فقط'
                                                    : 'التسجيل متاح'),
                                      style: TextStyle(
                                        color: isFull
                                            ? Colors.white
                                            : statusColor,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Bold Match Title
                          Text(
                            displayMatchTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 12),

                          // Frosted Glass Info & Progress Sub-Panel
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.stadium_rounded,
                                          size: 16,
                                          color: AppColors.owlLimeNeon,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '$title • $subtitle',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule_rounded,
                                          size: 16,
                                          color: AppColors.turfGreenNeon,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '$displayDate • الساعة $displayTime',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Attendance Row with Tabular Figures
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'الحضور: $confirmedPlayers من $totalSeats لاعب',
                                            style: AppTypography.tabular(
                                              const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          waitingCount > 0
                                              ? '$waitingCount في الانتظار'
                                              : (remaining == 0
                                                    ? 'اكتمل العدد'
                                                    : 'متبقي $remaining ${remaining > 10 ? "مقعداً" : "مقاعد"}'),
                                          style: AppTypography.tabular(
                                            const TextStyle(
                                              color: AppColors.owlLimeNeon,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: fillPercentage,
                                        minHeight: 7,
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.12),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          AppColors.turfGreenNeon,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 1-Tap RSVP Action Button
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isUserRegistered
                                  ? AppColors.turfGreenNeon
                                      .withValues(alpha: 0.16)
                                  : (!isRegistrationOpen
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isUserRegistered
                                    ? AppColors.turfGreenNeon
                                        .withValues(alpha: 0.5)
                                    : (!isRegistrationOpen
                                        ? Colors.white.withValues(alpha: 0.22)
                                        : Colors.transparent),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: !isRegistrationOpen
                                    ? null
                                    : (onRsvpTap ?? onTap),
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isUserRegistered
                                                ? Icons.check_circle_rounded
                                                : (!isRegistrationOpen
                                                    ? Icons.timer_outlined
                                                    : Icons
                                                        .sports_soccer_rounded),
                                            size: 19,
                                            color: isUserRegistered
                                                ? AppColors.turfGreenNeon
                                                : (!isRegistrationOpen
                                                    ? Colors.white70
                                                    : AppColors.primaryEmerald),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isUserRegistered
                                                ? 'أنت مسجل أساسي ✓ (اضغط للإلغاء)'
                                                : (!isRegistrationOpen &&
                                                        registrationOpensAt !=
                                                            null
                                                    ? 'يبدأ الحجز الساعة ${DateFormat('hh:mm a', 'ar').format(registrationOpensAt!)}'
                                                    : (isFull
                                                          ? 'الانضمام لقائمة الانتظار'
                                                          : 'تأكيد حضوري للمباراة')),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: isUserRegistered
                                                  ? AppColors.turfGreenNeon
                                                  : (!isRegistrationOpen
                                                      ? Colors.white70
                                                      : AppColors.darkSlate),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
        ),
      ),
    );
  }
}
