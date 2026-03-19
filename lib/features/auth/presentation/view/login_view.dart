import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/design_tokens.dart';
import '../widgets/auth_input.dart';
import '../viewmodel/login_vm.dart';
import '../widgets/password_input.dart';

class LoginView extends ConsumerWidget {
  const LoginView({
    super.key,
    required this.onGoSignup,
    required this.onGoForgot,
  });

  final VoidCallback onGoSignup;
  final VoidCallback onGoForgot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginVmProvider);
    final LoginVm vm = ref.read(loginVmProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(child: Image.asset('assets/images/logo.png', width: 80, height: 104,fit: BoxFit.cover,)),
        const SizedBox(height: 8),

        const Text(
          'تسجيل الدخول',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: DesignTokens.black,
          ),
        ),
        const SizedBox(height: 20),

        AuthInput(
          placeholder: 'البريد الإلكتروني',
          onChanged: vm.setEmail,
          errorText: state.emailError,
        ),
        const SizedBox(height: 14),

        // PasswordInput عندنا ما يدعم errorText
        // فهنستخدم AuthInput مباشرة هنا عشان نظهر error
        PasswordInput(
          placeholder: 'كلمة المرور',
          onChanged: vm.setPassword,
          errorText: state.passwordError,
        ),
        const SizedBox(height: 18),

        if (state.submitError != null) ...[
          Text(
            state.submitError!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Amiri', color: DesignTokens.red),
          ),
          const SizedBox(height: 10),
        ],

        SizedBox(
          height: 56,
          child: FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            onPressed: state.submitting
                ? null
                : () async {
              // ignore: avoid_print
              print('LOGIN BUTTON CLICKED');
              await vm.submitLogin();
              },
            child: state.submitting
                ? const ProgressRing()
                : const Text(
              'تسجيل الدخول',
              style: TextStyle(fontFamily: 'Amiri', color: DesignTokens.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 8),
        HyperlinkButton(
          onPressed: onGoForgot,
          child: const Text('نسيت كلمة المرور؟', style: TextStyle(fontFamily: 'Amiri', color: DesignTokens.brown)),
        ),

        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ليس لديك حساب؟ ', style: TextStyle(fontFamily: 'Amiri', color: DesignTokens.gray)),
            HyperlinkButton(
              onPressed: onGoSignup,
              child: const Text('إنشاء حساب', style: TextStyle(fontFamily: 'Amiri', color: DesignTokens.brown)),
            ),
          ],
        ),
      ],
    );
  }
}