import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import 'data/repositories/access_requests_repo.dart';
import 'data/repositories/access_requests_repo_impl.dart';
import 'data/sources/access_requests_remote_ds.dart';

final accessRequestsRemoteDsProvider = Provider<AccessRequestsRemoteDs>((ref) {
  final dio = ref.watch(dioProvider);
  return AccessRequestsRemoteDsImpl(dio);
});

final accessRequestsRepoProvider = Provider<AccessRequestsRepo>((ref) {
  final ds = ref.watch(accessRequestsRemoteDsProvider);
  return AccessRequestsRepoImpl(ds);
});
