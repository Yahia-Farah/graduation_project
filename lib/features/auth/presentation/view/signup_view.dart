import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_tokens.dart';
import '../viewmodel/signup_vm.dart';
import '../widgets/auth_input.dart';
import '../widgets/password_input.dart';

class SignupView extends ConsumerWidget {
  const SignupView({
    super.key,
    required this.onGoLogin,
    required this.onSignupSuccess,
  });

  final VoidCallback onGoLogin;
  final void Function(String email) onSignupSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SignupState>(signupVmProvider, (prev, next) {
      if (next.isSuccess && (prev == null || !prev.isSuccess)) {
        onSignupSuccess(next.email);
      }
    });

    final state = ref.watch(signupVmProvider);
    final vm = ref.read(signupVmProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 104,
                fit: BoxFit.cover,
              ),
              const Text(
                'إنشاء حساب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.brown,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'انضم إلى منظومة المستشار، يرجى إدخال بياناتك الرسمية بدقة لتفعيل حسابك.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: DesignTokens.gray),
              ),
              const SizedBox(height: 8),

              // ===== الاسم الأول + الأخير =====
              Row(
                children: [
                  Expanded(
                    child: AuthInput(
                      placeholder: 'الاسم الأول',
                      onChanged: vm.setFirstName,
                      errorText: state.firstNameError,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AuthInput(
                      placeholder: 'الاسم الأخير',
                      onChanged: vm.setLastName,
                      errorText: state.lastNameError,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              AuthInput(
                placeholder: 'البريد الإلكتروني',
                onChanged: vm.setEmail,
                errorText: state.emailError,
              ),
              const SizedBox(height: 8),

              AuthInput(
                placeholder: 'الرقم القومي',
                onChanged: vm.setNationalId,
                errorText: state.nationalIdError,
              ),
              const SizedBox(height: 18),

              // ===== كلمة المرور =====
              PasswordInput(
                placeholder: 'تعيين كلمة المرور',
                onChanged: vm.setPassword,
                errorText: state.passwordError,
              ),
              const SizedBox(height: 8),

              PasswordInput(
                placeholder: 'تأكيد كلمة المرور',
                onChanged: vm.setConfirmPassword,
                errorText: state.confirmPasswordError,
              ),
              const SizedBox(height: 8),

              if (state.submitError != null) ...[
                Text(
                  state.submitError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: DesignTokens.red),
                ),
                const SizedBox(height: 8),
              ],

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
                  onPressed: state.submitting ? null : vm.submitSignup,
                  child: state.submitting
                      ? const ProgressRing()
                      : const Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              HyperlinkButton(
                onPressed: onGoLogin,
                child: const Text(
                  'لديك حساب بالفعل؟ تسجيل الدخول',
                  style: TextStyle(color: DesignTokens.brown),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
