import 'package:dio/dio.dart';
import '../../../cases/domain/page_info.dart';
import '../../domain/notification_model.dart';
import 'notifications_repo.dart';
import '../sources/notifications_remote_ds.dart';

class NotificationsRepoImpl implements NotificationsRepo {
  final NotificationsRemoteDs _remoteDs;

  NotificationsRepoImpl(this._remoteDs);

  @override
  Future<NotificationsResult> getNotifications({int page = 0, int pageSize = 10}) async {
    try {
      final response = await _remoteDs.getNotifications(page: page, pageSize: pageSize);
      final json = response.data;
      if (json['success'] == true) {
        final dataList = json['data'] as List?;
        final notifications = dataList != null
            ? dataList.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList()
            : <NotificationModel>[];
            
        final pageInfoJson = json['pageInfo'];
        final pageInfo = pageInfoJson != null 
            ? PageInfo.fromJson(pageInfoJson as Map<String, dynamic>) 
            : PageInfo.empty;
            
        return NotificationsResult(notifications: notifications, pageInfo: pageInfo);
      } else {
        throw Exception(json['message'] ?? 'Failed to fetch notifications');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<NotificationModel> getNotification(String id) async {
    try {
      final response = await _remoteDs.getNotification(id);
      final json = response.data;
      if (json['success'] == true) {
        return NotificationModel.fromJson(json['data']);
      } else {
        throw Exception(json['message'] ?? 'Failed to fetch notification');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _remoteDs.getUnreadCount();
      final json = response.data;
      if (json['success'] == true) {
        final data = json['data'];
        return data != null ? (data as num).toInt() : 0;
      } else {
        throw Exception(json['message'] ?? 'Failed to fetch unread count');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      final response = await _remoteDs.deleteNotification(id);
      final json = response.data;
      if (json['success'] != true) {
        throw Exception(json['message'] ?? 'Failed to delete notification');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Network error');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
