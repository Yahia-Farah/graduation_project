import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../app/theme/design_tokens.dart';
import '../viewmodel/notifications_vm.dart';
import '../../domain/notification_model.dart';

class NotificationsFlyout extends ConsumerStatefulWidget {
  const NotificationsFlyout({super.key});

  @override
  ConsumerState<NotificationsFlyout> createState() => _NotificationsFlyoutState();
}

class _NotificationsFlyoutState extends ConsumerState<NotificationsFlyout> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when flyout opens
    Future.microtask(() => ref.read(notificationsVmProvider.notifier).fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsVmProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 350.w,
        height: 400.h,
        decoration: BoxDecoration(
          color: DesignTokens.white,
          borderRadius: BorderRadius.circular(DesignTokens.r20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'الإشعارات',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.brown,
                ),
              ),
            ),
            Container(height: 1.h, color: DesignTokens.lightGray),
            
            // List
            Expanded(
              child: state.isLoading
                  ? const Center(child: ProgressRing())
                  : state.error != null
                      ? Center(child: Text(state.error!, style: const TextStyle(color: DesignTokens.red)))
                      : state.notifications.isEmpty
                          ? Center(child: Text('لا توجد إشعارات', style: TextStyle(color: DesignTokens.gray, fontSize: 14.sp)))
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: state.notifications.length,
                              separatorBuilder: (context, index) => Container(height: 1.h, color: DesignTokens.lightGray),
                              itemBuilder: (context, index) {
                                final notification = state.notifications[index];
                                return _NotificationItem(notification: notification);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('yyyy/MM/dd hh:mm a');

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            margin: EdgeInsets.only(top: 6.h, left: 12.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: notification.read ? Colors.transparent : DesignTokens.brown,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                    color: DesignTokens.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: DesignTokens.gray,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  dateFormat.format(notification.createdAt),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: DesignTokens.gray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(FluentIcons.delete, color: DesignTokens.red),
            onPressed: () {
              ref.read(notificationsVmProvider.notifier).deleteNotification(notification.id);
            },
          ),
        ],
      ),
    );
  }
}
