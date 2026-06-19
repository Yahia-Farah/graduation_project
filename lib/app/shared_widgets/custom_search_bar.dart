import 'package:fluent_ui/fluent_ui.dart';
import '../theme/design_tokens.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefix;
  final Widget? suffix;
  final OverlayVisibilityMode? suffixMode;
  final TextAlign textAlign;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.prefix,
    this.suffix,
    this.suffixMode,
    this.textAlign = TextAlign.right,
  });

  @override
  Widget build(BuildContext context) {
    return TextBox(
      controller: controller,
      placeholder: placeholder,
      textAlign: textAlign,
      suffixMode: suffixMode ?? OverlayVisibilityMode.always,
      prefix: prefix,
      suffix: suffix ?? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(
          FluentIcons.search,
          size: 14,
          color: DesignTokens.gray,
        ),
      ),
      decoration: WidgetStateProperty.resolveWith((states) {
        return BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: states.contains(WidgetState.focused)
                ? DesignTokens.brown
                : DesignTokens.brown.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        );
      }),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
