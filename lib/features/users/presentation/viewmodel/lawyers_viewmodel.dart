import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/user_entity.dart';
import '../../users_providers.dart';

class LawyersViewModel extends AsyncNotifier<List<UserEntity>> {
  @override
  Future<List<UserEntity>> build() async {
    return _fetchLawyers();
  }

  Future<List<UserEntity>> _fetchLawyers() async {
    final repo = ref.read(usersRepoProvider);
    return await repo.getLawyers();
  }

  Future<void> deleteUser(String userId) async {
    final previousUsers = state.valueOrNull ?? [];
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(usersRepoProvider);
      await repo.deleteUser(userId);
      ref.invalidateSelf();
    } catch (e) {
      state = AsyncValue.data(previousUsers);
    }
  }

  Future<void> toggleUserStatus(UserEntity user) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(usersRepoProvider);
      await repo.toggleUserStatus(user.id, !user.isActive);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reviewLawyer(String lawyerId, bool isApproved) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(usersRepoProvider);
      await repo.reviewLawyer(lawyerId, isApproved);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final lawyersViewModelProvider =
    AsyncNotifierProvider<LawyersViewModel, List<UserEntity>>(LawyersViewModel.new);
