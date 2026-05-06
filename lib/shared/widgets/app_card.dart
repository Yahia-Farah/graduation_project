import 'package:fluent_ui/fluent_ui.dart';

import '../../app/theme/design_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? radius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(0),
      padding: padding ?? const EdgeInsets.all(DesignTokens.r20),
      decoration: BoxDecoration(
        color: backgroundColor ?? DesignTokens.white,
        borderRadius: BorderRadius.circular(radius ?? 12),
        border: Border.all(color: borderColor ?? DesignTokens.brown, width: 1),
      ),
      child: child,
    );
  }
}
