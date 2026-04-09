import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import 'data/repositories/users_repo.dart';
import 'data/repositories/users_repo_impl.dart';
import 'data/sources/users_remote_ds.dart';

final usersRepoProvider = Provider<UsersRepo>((ref) {
  final dio = ref.watch(dioProvider);
  return UsersRepoImpl(UsersRemoteDsImpl(dio));
});
