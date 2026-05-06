import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/theme/design_tokens.dart';

class AddCaseDialog extends StatelessWidget {
  const AddCaseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 700.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6F0), // beige background
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: DesignTokens.brown),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button (Left)
                  Container(
                    margin: EdgeInsets.only(top: 8.h),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: DesignTokens.brown),
                    ),
                    child: IconButton(
                      icon: Icon(
                        FluentIcons.cancel,
                        size: 12.sp,
                        color: DesignTokens.brown,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Spacer(),
                  // Title (Right)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'نموذج إضافة قضية جديدة',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.brown,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'يرجى ملء جميع التفاصيل التالية لإنشاء قضية جديدة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: DesignTokens.gray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Divider
            Container(height: 1, color: DesignTokens.brown),

            // Content
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: تعيين الأطراف
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'تعيين الأطراف',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: DesignTokens.brown,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInputField('اسم القاضي المعين له القضية'),
                        SizedBox(height: 16.h),
                        _buildInputField('المحامي'),
                      ],
                    ),
                  ),
                  SizedBox(width: 32.w),
                  // Right column: بيانات القضية
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'بيانات القضية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: DesignTokens.brown,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInputField('رقم القضية'),
                        SizedBox(height: 16.h),
                        _buildInputField('نوع القضية'),
                        SizedBox(height: 16.h),
                        _buildInputField(
                          'تاريخ تسجيل القضية',
                          icon: FluentIcons.calendar,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Divider
            Container(height: 1, color: DesignTokens.brown),

            // Action Button
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      DesignTokens.brown,
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'إضافة القضية',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String placeholder, {IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F6),
        border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextBox(
        placeholder: placeholder,
        textAlign: TextAlign.right,
        highlightColor: Colors.transparent,
        unfocusedColor: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        style: TextStyle(fontSize: 14.sp, color: DesignTokens.brown),
        placeholderStyle: TextStyle(fontSize: 14.sp, color: DesignTokens.gray),
        prefix: icon != null
            ? Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Icon(icon, size: 16.sp, color: DesignTokens.gray),
              )
            : null,
        decoration: WidgetStateProperty.all(
          const BoxDecoration(
            color: Colors.transparent,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.transparent, width: 0),
            ),
          ),
        ),
      ),
    );
  }
}
