import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../auth/presentation/viewmodel/auth_session.dart';
import 'data/repositories/case_details_repo.dart';
import 'data/repositories/case_details_repo_impl.dart';
import 'data/repositories/case_status_repo.dart';
import 'data/repositories/case_status_repo_impl.dart';
import 'data/repositories/cases_repo.dart';
import 'data/repositories/cases_repo_impl.dart';
import 'data/sources/case_remote_details_ds.dart';
import 'data/sources/case_status_remote_ds.dart';
import 'data/sources/cases_remote_ds.dart';

final casesRepoProvider = Provider<CasesRepo>((ref) {
  final dio = ref.watch(dioProvider);
  final session = ref.watch(authSessionProvider);

  return CasesRepoImpl(CasesRemoteDs(dio), () => (session.role ?? 'LAWYER'));
});

final caseDetailsRepoProvider = Provider<CaseDetailsRepo>((ref) {
  final dio = ref.watch(dioProvider);
  final session = ref.watch(authSessionProvider);

  return CaseDetailsRepoImpl(
    CaseDetailsRemoteDs(dio),
    () => session.role ?? 'LAWYER',
  );
});
final caseStatusRepoProvider = Provider<CaseStatusRepo>((ref) {
  final dio = ref.watch(dioProvider);
  final session = ref.watch(authSessionProvider);

  return CaseStatusRepoImpl(
    CaseStatusRemoteDs(dio),
    () => session.role ?? 'LAWYER',
  );
});
