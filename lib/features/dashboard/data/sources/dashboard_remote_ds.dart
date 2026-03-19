import 'package:dio/dio.dart';

class DashboardRemoteDs {
  DashboardRemoteDs(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> fetchSummary() async {
    final res = await _dio.get('/dashboard/summary'); // غيّرها حسب API عندك
    return Map<String, dynamic>.from(res.data as Map);
  }
}