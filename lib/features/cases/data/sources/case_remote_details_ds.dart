import 'package:dio/dio.dart';

class CaseDetailsRemoteDs {
  CaseDetailsRemoteDs(this._dio);
  final Dio _dio;

  Future<dynamic> fetchDetails({
    required String role,
    required String caseId,
  }) async {
    final path = _pathForRole(role, caseId);
    final res = await _dio.get(path);
    return res.data;
  }

  String _pathForRole(String role, String caseId) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return '/v1/admin/cases/$caseId';
      case 'JUDGE':
        return '/v1/judges/case/$caseId';
      case 'LAWYER':
        return '/v1/lawyer/cases/$caseId';
      default:
        return '/v1/lawyer/cases/$caseId';
    }
  }
}
