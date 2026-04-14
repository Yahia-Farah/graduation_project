import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_providers.dart';

class OtpState {
  final String otpCode;
  final bool submitting;
  final bool isSuccess;
  final String? errorText;

  const OtpState({
    this.otpCode = '',
    this.submitting = false,
    this.isSuccess = false,
    this.errorText,
  });

  OtpState copyWith({
    String? otpCode,
    bool? submitting,
    bool? isSuccess,
    String? errorText,
  }) {
    return OtpState(
      otpCode: otpCode ?? this.otpCode,
      submitting: submitting ?? this.submitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorText: errorText,
    );
  }
}

class OtpVm extends Notifier<OtpState> {
  @override
  OtpState build() => const OtpState();

  void setOtpCode(String code) {
    state = state.copyWith(otpCode: code, errorText: null);
  }

  Future<void> verifyOtp(String email) async {
    if (state.otpCode.trim().length < 4) {
      state = state.copyWith(errorText: 'رمز التحقق غير صالح');
      return;
    }

    state = state.copyWith(submitting: true, errorText: null, isSuccess: false);

    try {
      final repo = ref.read(authRepoProvider);
      await repo.verifyOtp(email: email, otpCode: state.otpCode.trim());

      state = state.copyWith(submitting: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        submitting: false,
        errorText: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final otpVmProvider = NotifierProvider<OtpVm, OtpState>(OtpVm.new);
