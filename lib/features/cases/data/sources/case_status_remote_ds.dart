import 'package:dio/dio.dart';

class CaseStatusRemoteDs {
  CaseStatusRemoteDs(this._dio);
  final Dio _dio;

  Future<dynamic> updateStatus({
    required String role, // ADMIN / JUDGE / LAWYER
    required String caseId,
    required String status, // PENDING / IN_PROGRESS / COMPLETED
  }) async {
    final path = _pathForRole(role, caseId);

    final res = await _dio.patch(
      path,
      data: {"status": status},
    );

    return res.data;
  }

  String _pathForRole(String role, String caseId) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return '/v1/admin/cases/$caseId/status';
      case 'JUDGE':
        return '/v1/judges/case/$caseId/status';
      default:
      // المحامي غالبًا مش مسموح له يغير status
        return '/v1/lawyer/cases/$caseId/status';
    }
  }
}