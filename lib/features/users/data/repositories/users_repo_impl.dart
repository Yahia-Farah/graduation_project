import '../../domain/user_entity.dart';
import '../sources/users_remote_ds.dart';
import 'users_repo.dart';

class UsersRepoImpl implements UsersRepo {
  final UsersRemoteDs remoteDs;

  UsersRepoImpl(this.remoteDs);

  @override
  Future<List<UserEntity>> getUsers() {
    return remoteDs.getUsers();
  }

  @override
  Future<List<UserEntity>> getLawyers() {
    return remoteDs.getLawyers();
  }

  @override
  Future<List<UserEntity>> getJudges() {
    return remoteDs.getJudges();
  }

  @override
  Future<UserEntity> createUser(UserEntity user) {
    return remoteDs.createUser(user);
  }

  @override
  Future<void> toggleUserStatus(String userId, bool activate) {
    return remoteDs.toggleUserStatus(userId, activate);
  }

  @override
  Future<void> deleteUser(String userId) {
    return remoteDs.deleteUser(userId);
  }

  @override
  Future<void> reviewLawyer(String lawyerId, bool isApproved) {
    return remoteDs.reviewLawyer(lawyerId, isApproved);
  }
}
