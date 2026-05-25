import '../../domain/access_request_entity.dart';
import '../sources/access_requests_remote_ds.dart';
import 'access_requests_repo.dart';

class AccessRequestsRepoImpl implements AccessRequestsRepo {
  final AccessRequestsRemoteDs remoteDs;

  AccessRequestsRepoImpl(this.remoteDs);

  @override
  Future<List<AccessRequestEntity>> getRequestsByStatus(String status) {
    return remoteDs.getRequestsByStatus(status);
  }

  @override
  Future<void> approveRequest(String requestId) {
    return remoteDs.approveRequest(requestId);
  }

  @override
  Future<void> rejectRequest(String requestId) {
    return remoteDs.rejectRequest(requestId);
  }
}
