import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/ai_analysis_model.dart';
import '../../ai_analysis_providers.dart';

/// Status of a single analysis task.
enum AnalysisTaskStatus { idle, running, completed, failed }

class AnalysisTask {
  final String caseId;
  final String caseNumber;
  final AnalysisTaskStatus status;
  final AiAnalysisResult? result;
  final String? error;

  const AnalysisTask({
    required this.caseId,
    required this.caseNumber,
    this.status = AnalysisTaskStatus.idle,
    this.result,
    this.error,
  });

  AnalysisTask copyWith({
    AnalysisTaskStatus? status,
    AiAnalysisResult? result,
    String? error,
  }) {
    return AnalysisTask(
      caseId: caseId,
      caseNumber: caseNumber,
      status: status ?? this.status,
      result: result ?? this.result,
      error: error,
    );
  }
}

class AiAnalysisState {
  /// Map of caseId → AnalysisTask
  final Map<String, AnalysisTask> tasks;

  /// The result that user wants to view (set when navigating to results page)
  final AiAnalysisResult? viewingResult;
  
  /// The case ID associated with the viewing result
  final String? viewingCaseId;

  const AiAnalysisState({
    this.tasks = const {},
    this.viewingResult,
    this.viewingCaseId,
  });

  AiAnalysisState copyWith({
    Map<String, AnalysisTask>? tasks,
    AiAnalysisResult? viewingResult,
    String? viewingCaseId,
    bool clearViewing = false,
  }) {
    return AiAnalysisState(
      tasks: tasks ?? this.tasks,
      viewingResult: clearViewing ? null : (viewingResult ?? this.viewingResult),
      viewingCaseId: clearViewing ? null : (viewingCaseId ?? this.viewingCaseId),
    );
  }

  /// Returns true if any task is currently running.
  bool get hasRunningTasks =>
      tasks.values.any((t) => t.status == AnalysisTaskStatus.running);

  /// Returns list of currently running tasks.
  List<AnalysisTask> get runningTasks =>
      tasks.values.where((t) => t.status == AnalysisTaskStatus.running).toList();

  /// Returns list of completed tasks (newest first).
  List<AnalysisTask> get completedTasks =>
      tasks.values.where((t) => t.status == AnalysisTaskStatus.completed).toList();

  /// Check if a specific case is being analyzed.
  bool isAnalyzing(String caseId) =>
      tasks[caseId]?.status == AnalysisTaskStatus.running;
}

class AiAnalysisVm extends Notifier<AiAnalysisState> {
  @override
  AiAnalysisState build() {
    return const AiAnalysisState();
  }

  /// Start analysis for a case. Returns immediately — runs in background.
  void startAnalysis(String caseId, String caseNumber) {
    // Don't start if already running
    if (state.isAnalyzing(caseId)) return;

    // Mark as running
    final newTasks = Map<String, AnalysisTask>.from(state.tasks);
    newTasks[caseId] = AnalysisTask(
      caseId: caseId,
      caseNumber: caseNumber,
      status: AnalysisTaskStatus.running,
    );
    state = state.copyWith(tasks: newTasks);

    // Fire and forget — runs in the background
    _runAnalysis(caseId, caseNumber);
  }

  Future<void> _runAnalysis(String caseId, String caseNumber) async {
    try {
      final repo = ref.read(aiAnalysisRepoProvider);
      final result = await repo.invokeAnalysis(caseId);

      final newTasks = Map<String, AnalysisTask>.from(state.tasks);
      newTasks[caseId] = AnalysisTask(
        caseId: caseId,
        caseNumber: caseNumber,
        status: AnalysisTaskStatus.completed,
        result: result,
      );
      state = state.copyWith(tasks: newTasks);
    } catch (e) {
      final newTasks = Map<String, AnalysisTask>.from(state.tasks);
      newTasks[caseId] = AnalysisTask(
        caseId: caseId,
        caseNumber: caseNumber,
        status: AnalysisTaskStatus.failed,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      state = state.copyWith(tasks: newTasks);
    }
  }

  /// Set the result to view on the results page.
  void viewResult(AiAnalysisResult result, {String? caseId}) {
    state = state.copyWith(viewingResult: result, viewingCaseId: caseId, clearViewing: false);
  }

  /// Fetch a saved result from the server and view it.
  Future<void> fetchSavedResult(String caseId) async {
    try {
      final repo = ref.read(aiAnalysisRepoProvider);
      final result = await repo.getSavedResult(caseId);
      viewResult(result, caseId: caseId);
    } catch (e) {
      // You could handle the error with a toast or some other mechanism
      rethrow;
    }
  }

  /// Clear the viewing result.
  void clearViewing() {
    state = state.copyWith(clearViewing: true);
  }

  /// Delete a saved result from the server.
  Future<void> deleteResult(String caseId) async {
    try {
      final repo = ref.read(aiAnalysisRepoProvider);
      await repo.deleteResult(caseId);
      clearViewing();
      dismissTask(caseId);
    } catch (e) {
      rethrow;
    }
  }

  /// Dismiss a completed/failed task from the list.
  void dismissTask(String caseId) {
    final newTasks = Map<String, AnalysisTask>.from(state.tasks);
    newTasks.remove(caseId);
    state = state.copyWith(tasks: newTasks);
  }
}

final aiAnalysisVmProvider =
    NotifierProvider<AiAnalysisVm, AiAnalysisState>(AiAnalysisVm.new);
