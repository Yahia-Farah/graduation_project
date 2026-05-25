import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/design_tokens.dart';


class TopBar extends ConsumerWidget {
  const TopBar({super.key, required this.pageTitle, this.onBellTap});

  final String pageTitle;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: const BoxDecoration(color: DesignTokens.beige),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Page title
                Expanded(
                  child: Text(
                    pageTitle,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.brown,
                    ),
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
            SizedBox(height: 10.h),
            Container(
              height: 1.h,
              width: double.infinity,
              color: DesignTokens.brown,
            ),
          ],
        ),
      ),
    );
  }
}
