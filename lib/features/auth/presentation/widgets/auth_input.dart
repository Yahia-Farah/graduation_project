import 'package:fluent_ui/fluent_ui.dart';
import '../../../../app/theme/design_tokens.dart';

class AuthInput extends StatefulWidget {
  const AuthInput({
    super.key,
    required this.placeholder,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.width,
    this.onChanged,
    this.errorText,
  });

  final String placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;
  final double? width;
  final ValueChanged<String>? onChanged;
  final String? errorText;


  @override
  State<AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  @override
  Widget build(BuildContext context) {
    final hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: widget.width,
          height: 56,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: DesignTokens.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError
                    ? DesignTokens.red
                    : DesignTokens.beige,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextBox(
                    highlightColor: Colors.transparent,
                    unfocusedColor: Colors.transparent,
                    controller: widget.controller,
                    obscureText: widget.obscureText,
                    textAlign: TextAlign.right,
                    placeholder: widget.placeholder,
                    onChanged: widget.onChanged, // 👈 هنا
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: DesignTokens.gray,
                    ),
                    placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: DesignTokens.gray,
                    ),
                    decoration: WidgetStateProperty.all(
                      const BoxDecoration(
                        color: Colors.transparent,
                        border: Border.fromBorderSide(
                          BorderSide(
                              color: Colors.transparent, width: 0),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.suffix != null) ...[
                  const SizedBox(width: 10),
                  widget.suffix!,
                ],
              ],
            ),
          ),
        ),

        // 👇 عرض رسالة الخطأ تحت الحقل
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13,
              color: DesignTokens.red,
            ),
          ),
        ],
      ],
    );
  }
}