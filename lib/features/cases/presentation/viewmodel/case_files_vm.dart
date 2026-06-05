import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../cases_providers.dart';
import '../../domain/case_details_model.dart';

class CaseFilesState {
  final List<CaseFile> files;
  final Map<String, double> uploadProgress; // fileName -> progress (0.0 to 1.0)
  final bool isLoading;
  final String? error;

  CaseFilesState({
    this.files = const [],
    this.uploadProgress = const {},
    this.isLoading = false,
    this.error,
  });

  CaseFilesState copyWith({
    List<CaseFile>? files,
    Map<String, double>? uploadProgress,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CaseFilesState(
      files: files ?? this.files,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CaseFilesViewModel extends StateNotifier<CaseFilesState> {
  CaseFilesViewModel(this.ref, this.caseId) : super(CaseFilesState()) {
    _loadFiles();
  }

  final Ref ref;
  final String caseId;

  Future<void> _loadFiles() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(casesRepoProvider);
      final caseData = await repo.getCaseById(caseId);
      
      List<CaseFile> caseFiles = [];
      if (caseData != null && caseData['data'] != null) {
        final rawFiles = caseData['data']['caseFiles'];
        if (rawFiles is List) {
          caseFiles = rawFiles.map((e) {
            if (e is Map<String, dynamic>) {
              return CaseFile.fromJson(e);
            }
            return CaseFile(id: '', fileName: e.toString(), fileUrl: '', fileType: '');
          }).toList();
        }
      }
      
      if (mounted) {
        state = state.copyWith(files: caseFiles, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    }
  }

  Future<void> uploadFiles(List<PlatformFile> pickedFiles) async {
    final repo = ref.read(casesRepoProvider);
    
    // Initialize progress to 0 for new files
    final currentProgress = Map<String, double>.from(state.uploadProgress);
    for (var file in pickedFiles) {
      currentProgress[file.name] = 0.0;
    }
    state = state.copyWith(uploadProgress: currentProgress);

    try {
      final multipartFiles = pickedFiles.map((f) {
        if (f.path != null) {
          return MultipartFile.fromFileSync(f.path!, filename: f.name);
        } else {
          return MultipartFile.fromBytes(f.bytes!, filename: f.name);
        }
      }).toList();

      await repo.uploadCaseFiles(
        caseId,
        multipartFiles,
        (sent, total) {
          if (!mounted) return;
          final progress = total != 0 ? sent / total : 0.0;
          final updatedProgress = Map<String, double>.from(state.uploadProgress);
          for (var file in pickedFiles) {
            updatedProgress[file.name] = progress;
          }
          state = state.copyWith(uploadProgress: updatedProgress);
        },
      );

      // Re-fetch files
      await _loadFiles();
      
      // Clear progress on success
      if (mounted) {
        final finalProgress = Map<String, double>.from(state.uploadProgress);
        for (var file in pickedFiles) {
          finalProgress.remove(file.name);
        }
        state = state.copyWith(uploadProgress: finalProgress);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: 'خطأ أثناء رفع الملفات: $e');
        // Clear progress on error
        final finalProgress = Map<String, double>.from(state.uploadProgress);
        for (var file in pickedFiles) {
          finalProgress.remove(file.name);
        }
        state = state.copyWith(uploadProgress: finalProgress);
      }
    }
  }

  Future<void> deleteFile(String fileId) async {
    final repo = ref.read(casesRepoProvider);
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await repo.deleteCaseFile(fileId);
      await _loadFiles();
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: 'خطأ أثناء حذف الملف: $e', isLoading: false);
      }
    }
  }
}

final caseFilesViewModelProvider = StateNotifierProvider.family<CaseFilesViewModel, CaseFilesState, String>((ref, caseId) {
  return CaseFilesViewModel(ref, caseId);
});
