import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.brown,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    dateText,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.gray,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // الخط اللي تحت التاريخ (زي الفيجما)
                  Container(
                    height: 1.h,
                    width: MediaQuery.of(context).size.width, // عدّلها حسب ما تحب
                    color: DesignTokens.brown
                  ),
                ],
              ),
            ),

            // زر الجرس (دائرة بيضاء)
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(360.r),
              ),
              child: IconButton(
                icon: Icon(
                  FluentIcons.ringer,
                  size: 18.sp,
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