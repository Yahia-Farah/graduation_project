import 'package:fluent_ui/fluent_ui.dart';
import 'package:graduation_project/app/root_decider.dart';
import 'theme/app_theme.dart';

class ElMostasharApp extends StatelessWidget {
  const ElMostasharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data,
      home: const RootDecider(),
    );
  }
}
