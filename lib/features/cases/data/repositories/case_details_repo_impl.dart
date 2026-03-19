import '../../domain/case_details_model.dart';
import '../../../auth/presentation/viewmodel/auth_session.dart';
import '../sources/case_remote_details_ds.dart';
import 'case_details_repo.dart';

class CaseDetailsRepoImpl implements CaseDetailsRepo {
  CaseDetailsRepoImpl(this._remote, this._getRole);

  final CaseDetailsRemoteDs _remote;
  final String Function() _getRole;

  @override
  Future<CaseDetailsModel> getDetails(String caseId) async {
    final role = _getRole();
    final body = await _remote.fetchDetails(
      role: role,
      caseId: caseId,
    );

    if (body is Map && body['data'] != null) {
      return CaseDetailsModel.fromJson(body['data']);
    }

    return CaseDetailsModel.fromJson(body);
  }
}