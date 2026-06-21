import 'package:fluent_ui/fluent_ui.dart';
import 'package:el_mostashar/app/theme/design_tokens.dart';

class AppTheme {
  static FluentThemeData get data {
    return FluentThemeData(
      brightness: Brightness.light,
      accentColor: AccentColor.swatch({"normal": DesignTokens.brown}),
      scaffoldBackgroundColor: DesignTokens.beige,
      fontFamily: 'Amiri',
    );
  }
}
