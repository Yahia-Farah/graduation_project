import '../../domain/ai_analysis_model.dart';

abstract class AiAnalysisRepo {
  Future<AiAnalysisResult> invokeAnalysis(String caseId);
  Future<AiAnalysisResult> getSavedResult(String caseId);
  Future<void> deleteResult(String caseId);
}
