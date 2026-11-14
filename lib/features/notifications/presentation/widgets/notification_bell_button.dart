import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_state.dart';

class NotificationBellButton extends StatelessWidget {
  final double size;

  const NotificationBellButton({
    super.key,
    this.size = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final defaultBg = isDark
        ? AppColors.darkSurfaceMuted.withValues(alpha: 0.75)
        : AppColors.surfaceMuted;

    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final unreadCount = state is NotificationsLoaded
            ? state.unreadCount
            : 0;

        return Tooltip(
          message: 'التنبيهات',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: defaultBg,
              border: Border.all(
                color: cs.outlineVariant,
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/notifications'),
                customBorder: const CircleBorder(),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      unreadCount > 0
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: cs.onSurface,
                      size: size * 0.48,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 3,
                        left: context.isRtl ? 3 : null,
                        right: context.isRtl ? null : 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blue.withValues(alpha: 0.35),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
