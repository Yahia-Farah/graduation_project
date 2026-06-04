import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/notification_model.dart';
import '../../notifications_providers.dart';

class NotificationsState {
  final int unreadCount;
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  NotificationsState({
    this.unreadCount = 0,
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    int? unreadCount,
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      unreadCount: unreadCount ?? this.unreadCount,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationsVm extends Notifier<NotificationsState> {
  Timer? _pollingTimer;

  @override
  NotificationsState build() {
    // Fetch initial unread count in the background
    Future.microtask(() => fetchUnreadCount());

    // Set up polling every minute
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      fetchUnreadCount();
    });

    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    return NotificationsState();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      final count = await repo.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to fetch unread count: $e');
    }
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(notificationsRepoProvider);
      // Fetching first page of notifications
      final result = await repo.getNotifications(page: 0, pageSize: 20);
      state = state.copyWith(
        notifications: result.notifications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final repo = ref.read(notificationsRepoProvider);
      await repo.deleteNotification(id);
      
      // Update local state optimistic deletion
      final newNotifications = state.notifications.where((n) => n.id != id).toList();
      state = state.copyWith(notifications: newNotifications);
      
      // Update unread count if needed
      await fetchUnreadCount();
    } catch (e) {
      // Revert or show error if deletion fails
      state = state.copyWith(error: 'Failed to delete notification');
    }
  }
}

final notificationsVmProvider = NotifierProvider<NotificationsVm, NotificationsState>(() {
  return NotificationsVm();
});
