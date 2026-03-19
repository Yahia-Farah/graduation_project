import 'package:dio/dio.dart';

class CasesRemoteDs {
  CasesRemoteDs(this._dio);
  final Dio _dio;

  Future<dynamic> fetchCases({
    required String role,
    required int page,
    required int pageSize,
    String? query,
    String? status,
  }) async {
    final path = _pathForRole(role);

    final res = await _dio.get(
      path,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (query != null && query.isNotEmpty) 'q': query,
        if (status != null && status != 'ALL') 'status': status,
      },
    );

    return res.data;
  }


  String _pathForRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return '/v1/admin/cases';
      case 'JUDGE':
        return '/v1/judges/all-cases';
      case 'LAWYER':
        return '/v1/lawyer/cases';
      default:
      // لو حصل role غير معروف
        return '/v1/lawyer/cases';
    }
  }
}