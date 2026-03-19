import 'package:fluent_ui/fluent_ui.dart';
import '../../../../app/theme/design_tokens.dart';
import 'auth_input.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    required this.placeholder,
    this.onChanged,
    this.errorText,
  });

  final String placeholder;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return AuthInput(
      placeholder: widget.placeholder,
      obscureText: hidden,
      onChanged: widget.onChanged,
      errorText: widget.errorText,

      // 👁️ زر العين (في RTL هيظهر على الشمال طبيعي داخل Row)
      suffix: IconButton(
        icon: Icon(
          hidden ? FluentIcons.red_eye : FluentIcons.hide,
          size: 18,
          color: DesignTokens.brown,
        ),
        onPressed: () => setState(() => hidden = !hidden),
      ),
    );
  }
}