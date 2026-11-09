import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../extensions/context_extensions.dart';

/// Hero Match / Stadium Card matching the large banner cards from the reference design.
class KickoffHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? rating;
  final String? fee;
  final String? distanceOrDate;
  final String? imageUrl;
  final VoidCallback? onTap;

  const KickoffHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.rating,
    this.fee,
    this.distanceOrDate,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Semantics(
      button: onTap != null,
      label: '$title, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image Container with Embedded Floating Pills
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image or Stadium Pitch Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF1B2C20),
                                    const Color(0xFF0F1A13),
                                  ]
                                : [
                                    const Color(0xFF3B5E30),
                                    const Color(0xFF21381A),
                                  ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackPitch(),
                              )
                            : _buildFallbackPitch(),
                      ),

                      // Floating distance / date pill (top trailing or bottom)
                      if (distanceOrDate != null)
                        Positioned(
                          top: 14,
                          left: context.isRtl ? 14 : null,
                          right: context.isRtl ? null : 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusCircular,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.near_me_rounded,
                                  size: 13,
                                  color: AppColors.darkSlate,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  distanceOrDate!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Carousel indicator dots on bottom
                      Positioned(
                        bottom: 12,
                        left: context.isRtl ? null : 16,
                        right: context.isRtl ? 16 : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.turfGreen,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                subtitle,
                                style: context.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (rating != null) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating!,
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (fee != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      fee!,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.turfGreenNeon
                            : AppColors.darkSlate,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPitch() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stadium_rounded,
            size: 48,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 6),
          Text(
            'Kickoff Arena',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
