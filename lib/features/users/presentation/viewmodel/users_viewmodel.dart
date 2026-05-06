import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/user_entity.dart';
import '../../users_providers.dart';
import '../../../auth/domain/user_role.dart';

class UsersViewModel extends AsyncNotifier<List<UserEntity>> {
  @override
  Future<List<UserEntity>> build() async {
    return _fetchUsers();
  }

  Future<List<UserEntity>> _fetchUsers() async {
    final repo = ref.read(usersRepoProvider);
    return await repo.getUsers();
  }

  Future<void> addUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int age,
    required String nationalId,
    required String court,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(usersRepoProvider);

      String roleString = 'UNKNOWN';
      if (role == UserRole.admin) roleString = 'ADMIN';
      if (role == UserRole.lawyer) roleString = 'LAWYER';
      if (role == UserRole.judge) roleString = 'JUDGE';

      final newUser = UserEntity(
        id: '',
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        age: age,
        nationalId: nationalId,
        court: court,
        role: roleString,
        isActive: true,
        assignedCasesCount: 0,
        isApproved: true,
      );

      await repo.createUser(newUser);
      state = AsyncValue.data(await _fetchUsers());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteUser(String userId) async {
    // Keep current list so we can do optimistic removal
    final previousUsers = state.valueOrNull ?? [];
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(usersRepoProvider);
      await repo.deleteUser(userId);
      // Optimistically remove the user from the local list
      final updated = previousUsers.where((u) => u.id != userId).toList();
      state = AsyncValue.data(updated);
    } catch (e) {
      // Revert to previous state on error
      state = AsyncValue.data(previousUsers);
    }
  }

  Future<void> toggleUserStatus(UserEntity user) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(usersRepoProvider);
      await repo.toggleUserStatus(user.id, !user.isActive);
      state = AsyncValue.data(await _fetchUsers());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final usersViewModelProvider =
    AsyncNotifierProvider<UsersViewModel, List<UserEntity>>(UsersViewModel.new);
