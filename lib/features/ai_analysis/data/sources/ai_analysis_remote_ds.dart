import 'package:dio/dio.dart';

class AiAnalysisRemoteDs {
  AiAnalysisRemoteDs(this._dio);
  final Dio _dio;

  /// Invokes AI analysis for a case.
  /// This call can take 6-7 minutes, so a long timeout is used.
  Future<dynamic> invokeAnalysis(String caseId) async {
    final res = await _dio.post(
      '/ai/invoke/$caseId',
      options: Options(
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(minutes: 1),
      ),
    );
    return res.data;
  }

  /// Fetches a saved AI analysis result.
  Future<dynamic> getSavedResult(String caseId) async {
    final res = await _dio.get('/v1/judges/cases/$caseId/result');
    return res.data;
  }
}
