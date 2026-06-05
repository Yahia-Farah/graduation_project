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
    String? date,
  }) async {
    String path = _pathForRole(role);
    if (role.toUpperCase() == 'JUDGE' && status != null && status != 'ALL') {
      path = '/v1/judges/status/$status';
    }

    final res = await _dio.get(
      path,
      queryParameters: {
        'page': page,
        'size': pageSize,
        if (query != null && query.isNotEmpty) 'q': query,
        if (role.toUpperCase() != 'JUDGE' && status != null && status != 'ALL') 'status': status,
        if (date != null && date.isNotEmpty) 'date': date,
      },
    );

    return res.data;
  }

  Future<void> createCase(Map<String, dynamic> data) async {
    await _dio.post('/v1/admin/cases', data: data);
  }

  Future<void> assignUser(String caseId, String userId) async {
    await _dio.patch('/v1/admin/cases/$caseId/assign/$userId');
  }

  Future<dynamic> getCaseById(String caseId) async {
    final res = await _dio.get('/v1/admin/cases/$caseId');
    return res.data;
  }

  Future<List<int>> getFileBytes(String role, String caseId, String fileName) async {
    final basePath = role.toUpperCase() == 'LAWYER' 
        ? '/v1/lawyer/cases/$caseId/files' 
        : '/v1/admin/cases/$caseId/files';
        
    final res = await _dio.get(
      '$basePath/$fileName',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data;
  }

  Future<void> uploadCaseFiles(
    String role,
    String caseId,
    List<MultipartFile> files,
    void Function(int, int) onProgress,
  ) async {
    final path = role.toUpperCase() == 'LAWYER'
        ? '/v1/lawyer/cases/$caseId/files'
        : '/v1/admin/cases/$caseId/files';

    final formData = FormData.fromMap({'files': files});
    await _dio.post(
      path,
      data: formData,
      onSendProgress: onProgress,
    );
  }

  Future<void> deleteCaseFile(String role, String fileId) async {
    final path = role.toUpperCase() == 'LAWYER'
        ? '/v1/lawyer/case-file/$fileId'
        : '/v1/admin/case-file/$fileId'; // Assuming admin path structure, adjust if needed
        
    await _dio.delete(path);
  }

  Future<void> requestAccess(String caseNumber) async {
    await _dio.post(
      '/v1/lawyer/cases/request-access',
      data: {'caseNumber': caseNumber},
    );
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
