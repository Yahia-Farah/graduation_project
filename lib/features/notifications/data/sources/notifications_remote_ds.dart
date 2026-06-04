import 'package:dio/dio.dart';

abstract class NotificationsRemoteDs {
  Future<Response> getNotifications({int page = 0, int pageSize = 10});
  Future<Response> getNotification(String id);
  Future<Response> getUnreadCount();
  Future<Response> deleteNotification(String id);
}

class NotificationsRemoteDsImpl implements NotificationsRemoteDs {
  final Dio _dio;

  NotificationsRemoteDsImpl(this._dio);

  @override
  Future<Response> getNotifications({int page = 0, int pageSize = 10}) async {
    return await _dio.get(
      '/v1/notifications',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );
  }

  @override
  Future<Response> getNotification(String id) async {
    return await _dio.get('/v1/notifications/$id');
  }

  @override
  Future<Response> getUnreadCount() async {
    return await _dio.get('/v1/notifications/unread-count');
  }

  @override
  Future<Response> deleteNotification(String id) async {
    return await _dio.delete('/v1/notifications/$id');
  }
}
