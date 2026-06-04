import '../../../cases/domain/page_info.dart';
import '../../domain/notification_model.dart';

class NotificationsResult {
  final List<NotificationModel> notifications;
  final PageInfo pageInfo;

  NotificationsResult({
    required this.notifications,
    required this.pageInfo,
  });
}

abstract class NotificationsRepo {
  Future<NotificationsResult> getNotifications({int page = 0, int pageSize = 10});
  Future<NotificationModel> getNotification(String id);
  Future<int> getUnreadCount();
  Future<void> deleteNotification(String id);
}
