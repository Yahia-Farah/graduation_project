import '../../domain/user_entity.dart';
import '../sources/users_remote_ds.dart';
import 'users_repo.dart';

class UsersRepoImpl implements UsersRepo {
  final UsersRemoteDs remoteDs;
  final Set<String> _deletedUserIds = {};

  UsersRepoImpl(this.remoteDs);

  @override
  Future<List<UserEntity>> getUsers() async {
    final users = await remoteDs.getUsers();
    return users.where((u) => !_deletedUserIds.contains(u.id)).toList();
  }

  @override
  Future<List<UserEntity>> getLawyers() async {
    final lawyers = await remoteDs.getLawyers();
    return lawyers.where((u) => !_deletedUserIds.contains(u.id)).toList();
  }

  @override
  Future<List<UserEntity>> getJudges() async {
    final judges = await remoteDs.getJudges();
    return judges.where((u) => !_deletedUserIds.contains(u.id)).toList();
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
  Future<void> deleteUser(String userId) async {
    await remoteDs.deleteUser(userId);
    _deletedUserIds.add(userId);
  }

  @override
  Future<void> reviewLawyer(String lawyerId, bool isApproved) {
    return remoteDs.reviewLawyer(lawyerId, isApproved);
  }
}
