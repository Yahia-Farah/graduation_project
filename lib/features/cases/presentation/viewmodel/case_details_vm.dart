import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cases_providers.dart';
import '../../domain/case_details_model.dart';
import '../../domain/case_status.dart';

class CaseDetailsState {
  final bool loading;
  final String? error;
  final CaseDetailsModel? data;

  final bool updatingStatus;
  final String? updateError;
  final bool updateSuccess;

  const CaseDetailsState({
    this.loading = false,
    this.error,
    this.data,
    this.updatingStatus = false,
    this.updateError,
    this.updateSuccess = false,
  });

  CaseDetailsState copyWith({
    bool? loading,
    String? error,
    CaseDetailsModel? data,
    bool? updatingStatus,
    String? updateError,
    bool? updateSuccess,
  }) {
    return CaseDetailsState(
      loading: loading ?? this.loading,
      error: error,
      data: data ?? this.data,
      updatingStatus: updatingStatus ?? this.updatingStatus,
      updateError: updateError,
      updateSuccess: updateSuccess ?? false,
    );
  }
}

class CaseDetailsVm extends Notifier<CaseDetailsState> {
  @override
  CaseDetailsState build() => const CaseDetailsState();

  Future<void> load(String caseId) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final repo = ref.read(caseDetailsRepoProvider);
      final data = await repo.getDetails(caseId);
      state = state.copyWith(loading: false, data: data);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }
  Future<void> changeStatus({
    required String caseId,
    required CaseStatus newStatus,
  }) async {
    // optimistic UI
    final current = state.data;
    if (current == null) return;

    state = state.copyWith(
      updatingStatus: true,
      updateError: null,
      updateSuccess: false,
      data: CaseDetailsModel(
        id: current.id,
        caseNumber: current.caseNumber,
        title: current.title,
        description: current.description,
        status: caseStatusToApi(newStatus),
        judgeName: current.judgeName,
        lawyerName: current.lawyerName,
        courtRuling: current.courtRuling,
        caseFiles: current.caseFiles,
        defenseFiles: current.defenseFiles,
      ),
    );

    try {
      final repo = ref.read(caseStatusRepoProvider);
      await repo.updateStatus(
        caseId: caseId,
        status: caseStatusToApi(newStatus),
      );

      state = state.copyWith(updatingStatus: false, updateSuccess: true);

      // اختياري: اعمل reload عشان تتأكد من السيرفر
      // await load(caseId);
    } catch (e) {
      // rollback
      state = state.copyWith(
        updatingStatus: false,
        updateError: e.toString().replaceFirst('Exception: ', ''),
        data: current,
      );
    }
  }
}

final caseDetailsVmProvider =
NotifierProvider<CaseDetailsVm, CaseDetailsState>(
    CaseDetailsVm.new);