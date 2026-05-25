import '../../domain/access_request_entity.dart';

abstract class AccessRequestsRepo {
  Future<List<AccessRequestEntity>> getRequestsByStatus(String status);
  Future<void> approveRequest(String requestId);
  Future<void> rejectRequest(String requestId);
}
