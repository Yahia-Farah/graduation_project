import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_tokens.dart';
import '../viewmodel/otp_vm.dart';
import '../widgets/auth_input.dart';

class OtpView extends ConsumerWidget {
  const OtpView({
    super.key,
    required this.email,
    required this.onVerified,
  });

  final String email;
  final VoidCallback onVerified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<OtpState>(otpVmProvider, (prev, next) {
      if (next.isSuccess && (prev == null || !prev.isSuccess)) {
        onVerified();
      }
    });

    final state = ref.watch(otpVmProvider);
    final vm = ref.read(otpVmProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 80,
            height: 104,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          const Text(
            'تأكيد الحساب',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: DesignTokens.brown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تم إرسال رمز التحقق إلى:\n$email',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: DesignTokens.gray,
            ),
          ),
          const SizedBox(height: 24),
          AuthInput(
            placeholder: 'رمز التحقق (OTP)',
            onChanged: vm.setOtpCode,
            errorText: state.errorText,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  DesignTokens.brown,
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              onPressed: state.submitting ? null : () => vm.verifyOtp(email),
              child: state.submitting
                  ? const ProgressRing()
                  : const Text(
                      'تأكيد',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
