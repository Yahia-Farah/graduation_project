import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/shell/home_shell.dart';
import '../../../../app/theme/design_tokens.dart';
import '../viewmodel/auth_session.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'otp_view.dart';
import 'forgot_password_view.dart';
import 'login_view.dart';
import 'signup_view.dart';

enum AuthPage { login, signup, forgot, otp }

class AuthShell extends ConsumerStatefulWidget {
  const AuthShell({super.key});

  @override
  ConsumerState<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends ConsumerState<AuthShell> {
  AuthPage page = AuthPage.login;
  String? registeredEmail;

  void go(AuthPage p) => setState(() => page = p);

  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (prev, next) {
      final wasAuthed = prev?.isAuthed ?? false;
    });
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ScaffoldPage(
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 40.h),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: DesignTokens.brown),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                   Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 56.w, vertical: 24.h),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 100),
                        child: _buildForm(),
                      ),
                    ),
                  ),
                  Expanded(flex: 8, child: _LeftImage()),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (page) {
      case AuthPage.login:
        return LoginView(
          onGoForgot: () => go(AuthPage.forgot),
          key: const ValueKey('login'),
          onGoSignup: () => go(AuthPage.signup),
        );
      case AuthPage.signup:
        return SignupView(
          key: const ValueKey('signup'),
          onGoLogin: () => go(AuthPage.login),
          onSignupSuccess: (email) {
            setState(() {
              registeredEmail = email;
              page = AuthPage.otp;
            });
          },
        );
      case AuthPage.forgot:
        return ForgotPasswordView(
          key: const ValueKey('forgot'),
          onGoLogin: () => go(AuthPage.login),
        );
      case AuthPage.otp:
        return OtpView(
          key: const ValueKey('otp'),
          email: registeredEmail ?? '',
          onVerified: () {
            showDialog(
              context: context,
              builder: (ctx) => ContentDialog(
                title: const Text('نجاح'),
                content: const Text('تم تفعيل الحساب بنجاح، يمكنك الآن تسجيل الدخول.'),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      go(AuthPage.login);
                    },
                    child: const Text('حسناً'),
                  ),
                ],
              ),
            );
          },
        );
    }
  }
}

class _LeftImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/court_image.png', fit: BoxFit.fill),
      ],
    );
  }
}
