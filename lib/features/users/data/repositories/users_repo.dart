import '../../domain/user_entity.dart';

abstract class UsersRepo {
  Future<List<UserEntity>> getUsers();
  Future<UserEntity> createUser(UserEntity user);
  Future<void> toggleUserStatus(String userId, bool activate);
  Future<void> deleteUser(String userId);
}
