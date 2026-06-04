import 'package:dio/dio.dart';
import '../../domain/access_request_entity.dart';

abstract class AccessRequestsRemoteDs {
  Future<List<AccessRequestEntity>> getRequestsByStatus(String status);
  Future<void> approveRequest(String requestId);
  Future<void> rejectRequest(String requestId);
}

class AccessRequestsRemoteDsImpl implements AccessRequestsRemoteDs {
  final Dio dio;

  AccessRequestsRemoteDsImpl(this.dio);

  @override
  Future<List<AccessRequestEntity>> getRequestsByStatus(String status) async {
    final res = await dio.get('/v1/admin/users/lawyer-access/status', queryParameters: {
      'status': status,
    });
    
    final responseData = res.data;
    List<dynamic> rawList = [];

    if (responseData is Map && responseData.containsKey('data')) {
      final nestedData = responseData['data'];
      if (nestedData is Map && nestedData.containsKey('content') && nestedData['content'] is List) {
        rawList = nestedData['content'] as List;
      }
    }

    if (rawList.isNotEmpty) {
      return rawList.map((e) {
        try {
          return AccessRequestEntity.fromJson(e as Map<String, dynamic>);
        } catch (err) {
          // ignore: avoid_print
          print('Error parsing AccessRequestEntity: $err');
          return AccessRequestEntity(
            requestId: e['requestId']?.toString() ?? '',
            lawyerId: '',
            lawyerName: 'Error',
            caseId: '',
            caseNumber: '',
            status: status,
          );
        }
      }).toList();
    }

    return [];
  }

  @override
  Future<void> approveRequest(String requestId) async {
    await dio.put('/v1/admin/users/lawyer-access/$requestId/approve');
  }

  @override
  Future<void> rejectRequest(String requestId) async {
    await dio.put('/v1/admin/users/lawyer-access/$requestId/reject');
  }
}
