import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../cases/cases_providers.dart';
import '../../../cases/data/repositories/cases_repo.dart';

class LawyerDashboardState {
  final bool isRequestingAccess;
  final String? requestError;
  final String? requestSuccessMessage;

  const LawyerDashboardState({
    this.isRequestingAccess = false,
    this.requestError,
    this.requestSuccessMessage,
  });

  LawyerDashboardState copyWith({
    bool? isRequestingAccess,
    String? requestError,
    String? requestSuccessMessage,
  }) {
    return LawyerDashboardState(
      isRequestingAccess: isRequestingAccess ?? this.isRequestingAccess,
      requestError: requestError,
      requestSuccessMessage: requestSuccessMessage,
    );
  }
}

class LawyerDashboardVm extends StateNotifier<LawyerDashboardState> {
  final CasesRepo _casesRepo;

  LawyerDashboardVm(this._casesRepo) : super(const LawyerDashboardState());

  Future<void> requestAccess(String caseNumber) async {
    if (caseNumber.isEmpty) {
      state = state.copyWith(requestError: 'الرجاء إدخال رقم القضية');
      return;
    }

    state = state.copyWith(isRequestingAccess: true, requestError: null, requestSuccessMessage: null);

    try {
      await _casesRepo.requestAccess(caseNumber);
      state = state.copyWith(
        isRequestingAccess: false,
        requestSuccessMessage: 'لقد تم استلام طلب الوصول إلى القضية رقم ($caseNumber) بنجاح. طلبك الآن قيد المراجعة من قبل الإدارة، وسنوافيك بإشعار فور اتخاذ القرار',
      );
    } catch (e) {
      state = state.copyWith(
        isRequestingAccess: false,
        requestError: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(requestError: null, requestSuccessMessage: null);
  }
}

final lawyerDashboardVmProvider = StateNotifierProvider<LawyerDashboardVm, LawyerDashboardState>((ref) {
  return LawyerDashboardVm(ref.watch(casesRepoProvider));
});
