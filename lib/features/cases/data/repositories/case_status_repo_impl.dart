import 'package:dio/dio.dart';
import '../sources/case_status_remote_ds.dart';
import 'case_status_repo.dart';

class CaseStatusRepoImpl implements CaseStatusRepo {
  CaseStatusRepoImpl(this._remote, this._getRole);

  final CaseStatusRemoteDs _remote;
  final String Function() _getRole;

  @override
  Future<void> updateStatus({
    required String caseId,
    required String status,
  }) async {
    try {
      final role = _getRole();
      await _remote.updateStatus(role: role, caseId: caseId, status: status);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'تعذر تغيير حالة القضية';
      throw Exception(msg);
    }
  }
}