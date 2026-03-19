import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/theme/design_tokens.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(title: "القضايا المكتملة", value: "57"),
                _StatCard(title: "القضايا الجاري تحليلها", value: "12"),
                _StatCard(title: "القضايا الجديدة", value: "130"),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text(title, style: TextStyle(
              fontFamily: "Amiri",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ))],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "$value قضية",
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: "Amiri",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DesignTokens.brown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
