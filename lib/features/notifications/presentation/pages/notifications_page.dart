import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/enums/notification_type.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/presentation/states/app_states.dart';
import '../../../../core/presentation/widgets/kickoff_responsive_shell.dart';
import '../../../../core/presentation/widgets/kickoff_top_bar.dart';
import '../../../../core/services/firebase_notification_sender_service.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const LoadNotificationsRequested());
  }

  Future<void> _showBroadcastDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSending = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            final isDark = context.isDarkMode;
            final cs = Theme.of(context).colorScheme;
            final accent = isDark ? AppColors.blueNeon : AppColors.blueAccent;
            final emerald = isDark
                ? AppColors.turfGreenNeon
                : AppColors.primaryEmerald;
            final bottomPadding = MediaQuery.of(
              dialogContext,
            ).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: bottomPadding + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cs.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accent.withValues(
                              alpha: isDark ? 0.16 : 0.10,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            Icons.campaign_rounded,
                            color: accent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إرسال إشعار فوري لجميع الأصدقاء',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'سيصل الإشعار لجميع الأجهزة المشتركة عبر FCM',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان الإشعار',
                        hintText: 'أدخل عنوان الإشعار',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'يرجى كتابة عنوان للإشعار'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'نص الرسالة أو التنبيه',
                        hintText: 'اكتب رسالتك لجميع الأصدقاء هنا...',
                        prefixIcon: Icon(Icons.message_rounded),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'يرجى كتابة نص الإشعار'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: emerald,
                          foregroundColor: isDark
                              ? AppColors.canvasDark
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isSending
                            ? null
                            : () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  setModalState(() => isSending = true);
                                  final title = titleController.text.trim();
                                  final body = messageController.text.trim();

                                  final sender =
                                      sl<FirebaseNotificationSenderService>();
                                  final success = await sender
                                      .sendAdminBroadcast(
                                        title: title,
                                        message: body,
                                      );

                                  if (context.mounted) {
                                    Navigator.of(dialogContext).pop();
                                    if (success) {
                                      context.showSuccessToast(
                                        'تم إرسال الإشعار لجميع الأجهزة بنجاح 🚀',
                                      );
                                    } else {
                                      context.showErrorToast(
                                        'تعذر إرسال الإشعار، تحقق من الاتصال بالإنترنت',
                                      );
                                    }
                                  }
                                }
                              },
                        child: isSending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'إرسال فوري للأجهزة',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc?>()?.state;
    final isAdmin = authState is Authenticated && authState.isAdmin;

    return KickoffResponsiveShell(
      child: Scaffold(
        appBar: KickoffTopBar(
          title: 'مركز التنبيهات والإشعارات',
          actions: [
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                final hasUnread =
                    state is NotificationsLoaded && state.unreadCount > 0;
                if (!hasUnread) return const SizedBox.shrink();

                return TextButton(
                  onPressed: () {
                    context.read<NotificationsBloc>().add(
                      const MarkAllNotificationsAsReadRequested(),
                    );
                  },
                  child: Text(
                    'قراءة الكل',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: () => _showBroadcastDialog(context),
                backgroundColor: context.isDarkMode
                    ? AppColors.turfGreenNeon
                    : AppColors.primaryEmerald,
                foregroundColor: context.isDarkMode
                    ? AppColors.canvasDark
                    : Colors.white,
                icon: const Icon(Icons.campaign_rounded),
                label: const Text(
                  'إرسال تنبيه للأصدقاء',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : null,
        body: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const AppLoadingWidget(message: 'جاري تحميل الإشعارات...');
            }

            if (state is NotificationsErrorState) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<NotificationsBloc>().add(
                    const LoadNotificationsRequested(),
                  );
                },
              );
            }

            if (state is NotificationsEmptyState ||
                (state is NotificationsLoaded && state.notifications.isEmpty)) {
              return AppEmptyStateWidget(
                title: 'لا توجد إشعارات حالياً',
                message:
                    'ستصلك هنا تنبيهات المباريات وتأكيدات التشكيلة واستطلاعات الرأي.',
                actionLabel: 'تحديث',
                onAction: () {
                  context.read<NotificationsBloc>().add(
                    const LoadNotificationsRequested(),
                  );
                },
              );
            }

            if (state is NotificationsLoaded) {
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = state.notifications[index];
                  return NotificationTile(
                    notification: item,
                    onTap: () {
                      if (!item.isRead) {
                        context.read<NotificationsBloc>().add(
                          MarkNotificationAsReadRequested(item.id),
                        );
                      }

                      // Navigate to target if applicable
                      if (item.type == NotificationType.motmPollStarted) {
                        context.push('/polls');
                      } else if (item.targetId != null) {
                        context.push('/match-details');
                      }
                    },
                  );
                },
              );
            }

            return const AppLoadingWidget(message: 'جاري تحميل الإشعارات...');
          },
        ),
      ),
    );
  }
}
