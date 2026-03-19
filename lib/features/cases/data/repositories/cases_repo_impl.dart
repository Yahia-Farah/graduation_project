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
  @override
  Future<CasesResult> getCases({
    required int page,
    required int pageSize,
    String? query,
  }) async {
    try {
      final role = _getRole();
      final body = await _remote.fetchCases(
        role: role,
        page: page,
        pageSize: pageSize,
        query: query,
      );

      if (body is! Map) {
        return const CasesResult(items: [], pageInfo: PageInfo.empty);
      }

      final dataList = (body['data'] is List) ? (body['data'] as List) : const [];
      final items = dataList
          .whereType<Map>()
          .map((e) => CaseModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final pageInfoJson =
      (body['pageInfo'] is Map) ? Map<String, dynamic>.from(body['pageInfo']) : <String, dynamic>{};

      final pageInfo = pageInfoJson.isEmpty ? PageInfo.empty : PageInfo.fromJson(pageInfoJson);

      return CasesResult(items: items, pageInfo: pageInfo);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'تعذر تحميل القضايا';
      throw Exception(msg);
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic body) {
    if (body is List) {
      return body.cast<Map<String, dynamic>>();
    }
    if (body is Map) {
      // أشهر أشكال:
      // { data: [..] } أو { content: [..] } أو { cases: [..] }
      for (final key in ['data', 'content', 'cases', 'items']) {
        final v = body[key];
        if (v is List) return v.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }
}