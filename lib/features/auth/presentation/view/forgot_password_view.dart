import 'package:fluent_ui/fluent_ui.dart';
import '../../../../app/theme/design_tokens.dart';
import '../widgets/auth_input.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key, required this.onGoLogin});
  final VoidCallback onGoLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Image.asset('assets/images/logo.png', width: 70, height: 70),
        ),
        const SizedBox(height: 8),
        const Text(
          'نسيت كلمة المرور',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: DesignTokens.black,
          ),
        ),
        const SizedBox(height: 20),

        const AuthInput(
          placeholder: 'البريد الإلكتروني',
        ),
        const SizedBox(height: 18),

        FilledButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(DesignTokens.brown),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          onPressed: () {},
          child: const Text(
            'إرسال رابط الاستعادة',
            style: TextStyle(
              color: DesignTokens.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 10),
        HyperlinkButton(
          onPressed: onGoLogin,
          child: const Text(
            'رجوع لتسجيل الدخول',
            style: TextStyle(color: DesignTokens.brown),
          ),
        ),
      ],
    );
  }
}
