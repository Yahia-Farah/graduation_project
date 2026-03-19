import 'package:fluent_ui/fluent_ui.dart';
import '../theme/design_tokens.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    this.userName = 'معالي المستشار/ هادة عباس',
    this.dateText = 'الخميس، 29 يناير 2026',
    this.onBellTap,
  });

  final String userName;
  final String dateText;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: DesignTokens.beige,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مساحة المحتوى (الاسم + التاريخ + الخط)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // RTL: start = يمين
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.brown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.gray,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // الخط اللي تحت التاريخ (زي الفيجما)
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width, // عدّلها حسب ما تحب
                    color: DesignTokens.brown
                  ),
                ],
              ),
            ),

            // زر الجرس (دائرة بيضاء)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(360),
              ),
              child: IconButton(
                icon: const Icon(
                  FluentIcons.ringer,
                  size: 18,
                  color: DesignTokens.brown,
                ),
                onPressed: onBellTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}