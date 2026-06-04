import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';
import 'data/sources/ai_analysis_remote_ds.dart';
import 'data/repositories/ai_analysis_repo.dart';
import 'data/repositories/ai_analysis_repo_impl.dart';

final aiAnalysisRemoteDsProvider = Provider<AiAnalysisRemoteDs>((ref) {
  final dio = ref.watch(dioProvider);
  return AiAnalysisRemoteDs(dio);
});

final aiAnalysisRepoProvider = Provider<AiAnalysisRepo>((ref) {
  final remoteDs = ref.watch(aiAnalysisRemoteDsProvider);
  return AiAnalysisRepoImpl(remoteDs);
});
