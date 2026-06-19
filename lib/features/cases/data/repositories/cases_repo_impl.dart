import 'package:dio/dio.dart';
import '../../domain/case_model.dart';
import '../../domain/page_info.dart';
import '../sources/cases_remote_ds.dart';
import 'cases_repo.dart';

class CasesRepoImpl implements CasesRepo {
  CasesRepoImpl(this._remote, this._getRole);

  final CasesRemoteDs _remote;
  final String Function() _getRole;

  @override
  Future<void> createCase(Map<String, dynamic> data) async {
    try {
      await _remote.createCase(data);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : 'تعذر إضافة القضية';
      throw Exception(msg);
    }
  }

  @override
  Future<CasesResult> getCases({
    required int page,
    required int pageSize,
    String? query,
    String? status,
    String? date,
  }) async {
    try {
      final role = _getRole();
      final body = await _remote.fetchCases(
        role: role,
        page: page,
        pageSize: pageSize,
        query: query,
        status: status,
        date: date,
      );

      if (body is! Map) {
        return const CasesResult(items: [], pageInfo: PageInfo.empty);
      }

      List<dynamic> dataList = [];
      if (body['data'] is List) {
        dataList = body['data'] as List;
      } else if (body['data'] is Map && body['data']['content'] is List) {
        dataList = body['data']['content'] as List;
      } else if (body['content'] is List) {
        dataList = body['content'] as List;
      }
      final items = dataList
          .whereType<Map>()
          .map((e) => CaseModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      Map<String, dynamic> pageInfoJson = {};
      if (body['pageInfo'] is Map) {
        pageInfoJson = Map<String, dynamic>.from(body['pageInfo']);
      } else if (body['data'] is Map && body['data']['pageable'] != null) {
        final dataMap = body['data'] as Map;
        pageInfoJson = {
          'currentPage': dataMap['number'] ?? 0,
          'totalPages': dataMap['totalPages'] ?? 0,
          'totalElements': dataMap['totalElements'] ?? 0,
          'pageSize': dataMap['size'] ?? 0,
          'hasNext': dataMap['last'] == false,
          'hasPrevious': dataMap['first'] == false,
        };
      }

      final pageInfo = pageInfoJson.isEmpty
          ? PageInfo.empty
          : PageInfo.fromJson(pageInfoJson);

      return CasesResult(items: items, pageInfo: pageInfo);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'تعذر تحميل القضايا';
      throw Exception(msg);
    }
  }

  @override
  Future<void> assignUser(String caseId, String userId) async {
    try {
      await _remote.assignUser(caseId, userId);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'تعذر تعيين المستخدم';
      throw Exception(msg);
    }
  }

  @override
  Future<dynamic> getCaseById(String caseId) async {
    try {
      return await _remote.getCaseById(caseId);
    } catch (e) {
      throw Exception('تعذر جلب بيانات القضية: $e');
    }
  }

  @override
  Future<void> requestAccess(String caseNumber) async {
    try {
      await _remote.requestAccess(caseNumber);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : 'تعذر ارسال الطلب';
      throw Exception(msg);
    }
  }

  @override
  Future<List<dynamic>> getSentRequests(String status) async {
    try {
      final body = await _remote.getSentRequests(status);
      if (body is Map && body['data'] is List) {
        return body['data'] as List<dynamic>;
      } else if (body is List) {
        return body;
      }
      return [];
    } on DioException catch (e) {
      final msg = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : 'تعذر جلب الطلبات المرسلة';
      throw Exception(msg);
    }
  }

  @override
  Future<void> deleteCaseFile(String fileId) async {
    try {
      await _remote.deleteCaseFile(_getRole(), fileId);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response?.data['message'].toString()
          : 'تعذر حذف الملف';
      throw Exception(msg);
    }
  }

  @override
  Future<List<int>> getFileBytes(String caseId, String fileName) async {
    try {
      return await _remote.getFileBytes(_getRole(), caseId, fileName);
    } catch (e) {
      throw Exception('تعذر جلب بيانات الملف: $e');
    }
  }

  @override
  Future<void> uploadCaseFiles(
    String caseId,
    List<MultipartFile> files,
    void Function(int, int) onProgress,
  ) async {
    try {
      await _remote.uploadCaseFiles(_getRole(), caseId, files, onProgress);
    } catch (e) {
      throw Exception('تعذر رفع الملفات: $e');
    }
  }
}
