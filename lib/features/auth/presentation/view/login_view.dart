import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/theme/design_tokens.dart';
import '../widgets/auth_input.dart';
import '../viewmodel/login_vm.dart';
import '../widgets/password_input.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8.h),
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 80.w,
              height: 104.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8.h),

          Text(
            'تسجيل الدخول',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: DesignTokens.brown,
            ),
          ),
          SizedBox(height: 20.h),

          AuthInput(
            placeholder: 'البريد الإلكتروني',
            onChanged: vm.setEmail,
            errorText: state.emailError,
          ),
          SizedBox(height: 14.h),

          // PasswordInput عندنا ما يدعم errorText
          // فهنستخدم AuthInput مباشرة هنا عشان نظهر error
          PasswordInput(
            placeholder: 'كلمة المرور',
            onChanged: vm.setPassword,
            errorText: state.passwordError,
          ),
          SizedBox(height: 18.h),

          if (state.submitError != null) ...[
            Text(
              state.submitError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                color: DesignTokens.red,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 10.h),
          ],

          SizedBox(
            height: 56.h,
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
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
                  : Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: DesignTokens.beige,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 8.h),
          HyperlinkButton(
            onPressed: onGoForgot,
            child: Text(
              'نسيت كلمة المرور؟',
              style: TextStyle(
                fontFamily: 'Amiri',
                color: DesignTokens.brown,
                fontSize: 14.sp,
              ),
            ),
          ),

          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ليس لديك حساب؟ ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: DesignTokens.gray,
                  fontSize: 14.sp,
                ),
              ),
              HyperlinkButton(
                onPressed: onGoSignup,
                child: Text(
                  'إنشاء حساب',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: DesignTokens.brown,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
