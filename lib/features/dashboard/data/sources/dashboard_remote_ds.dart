import 'package:dio/dio.dart';

class DashboardRemoteDs {
  DashboardRemoteDs(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> fetchSummary() async {
    int accessRequests = 0;
    int lawyerRequests = 0;
    int unassignedCases = 0;

    // 1. Pending access requests (طلبات الوصول للقضايا)
    try {
      final res = await _dio.get(
        '/v1/admin/users/lawyer-access/status',
        queryParameters: {'status': 'PENDING'},
      );
      final data = res.data;
      if (data is Map && data['data'] is Map) {
        if (data['data']['totalElements'] != null) {
          accessRequests = (data['data']['totalElements'] as num).toInt();
        } else if (data['data']['content'] is List) {
          accessRequests = (data['data']['content'] as List).length;
        }
      } else if (data is List) {
        accessRequests = data.length;
      } else if (data is Map && data['data'] is List) {
        accessRequests = (data['data'] as List).length;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching access requests for dashboard: $e');
    }

    // 2. Lawyers waiting to be activated (طلبات انضمام المحامون)
    try {
      final res = await _dio.get('/v1/admin/users/lawyers?size=1000');
      final data = res.data;
      List<dynamic> rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map) {
        for (final key in ['data', 'content', 'users', 'items']) {
          if (data[key] is List) {
            rawList = data[key] as List;
            break;
          }
        }
        if (rawList.isEmpty && data['data'] is Map) {
          final nested = data['data'];
          if (nested['content'] is List) {
            rawList = nested['content'] as List;
          } else if (nested['items'] is List) {
            rawList = nested['items'] as List;
          }
        }
      }
      lawyerRequests = rawList.where((e) => e['isApproved'] == false).length;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching lawyer requests for dashboard: $e');
    }

    // 3. Unassigned cases (القضايا الغير موكلة)
    try {
      final res = await _dio.get('/v1/admin/cases', queryParameters: {
        'page': 0,
        'pageSize': 1000,
      });
      final data = res.data;
      List<dynamic> rawList = [];
      if (data is Map && data['data'] is List) {
        rawList = data['data'];
      } else if (data is Map && data['data'] is Map && data['data']['content'] is List) {
        rawList = data['data']['content'];
      } else if (data is List) {
        rawList = data;
      } else if (data is Map && data['content'] is List) {
        rawList = data['content'];
      }
      
      unassignedCases = rawList.where((e) {
        final lawyerName = e['lawyerName'];
        return lawyerName == null || lawyerName.toString().trim().isEmpty;
      }).length;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching unassigned cases for dashboard: $e');
    }

    return {
      'accessRequests': accessRequests,
      'lawyerRequests': lawyerRequests,
      'unassignedCases': unassignedCases,
    };
  }
}
