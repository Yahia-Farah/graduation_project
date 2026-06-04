import 'package:dio/dio.dart';
import '../../domain/ai_analysis_model.dart';
import '../sources/ai_analysis_remote_ds.dart';
import 'ai_analysis_repo.dart';

class AiAnalysisRepoImpl implements AiAnalysisRepo {
  final AiAnalysisRemoteDs _remoteDs;

  AiAnalysisRepoImpl(this._remoteDs);

  @override
  Future<AiAnalysisResult> invokeAnalysis(String caseId) async {
    try {
      final json = await _remoteDs.invokeAnalysis(caseId);
      if (json is Map<String, dynamic>) {
        return AiAnalysisResult.fromJson(json);
      } else {
        throw Exception('استجابة غير صالحة من الخادم');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('انتهت مهلة التحليل — حاول مرة أخرى');
      }
      throw Exception(
          e.response?.data?['message'] ?? 'خطأ في الشبكة أثناء التحليل');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AiAnalysisResult> getSavedResult(String caseId) async {
    try {
      final json = await _remoteDs.getSavedResult(caseId);
      if (json is Map<String, dynamic> && json['data'] != null) {
        return AiAnalysisResult.fromJson(json['data']);
      } else {
        throw Exception('استجابة غير صالحة من الخادم');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'تعذر تحميل النتائج المحفوظة');
    } catch (e) {
      rethrow;
    }
  }
}
