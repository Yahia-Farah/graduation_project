import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/viewmodel/auth_session.dart';
import '../theme/design_tokens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'menu_items.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<AppMenuItem> items;
  final logo = "assets/images/logo.png";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260.w, // أو DesignTokens.sidebarWidth لو حطيتها
      padding: EdgeInsets.only(right: 16.w),
      decoration: const BoxDecoration(color: DesignTokens.beige),
      child: Column(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo area
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Image.asset(
              logo,
              width: 137.w,
              height: 167.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(items.length, (index) {
            final item = items[index];

            return _MenuItem(
              index: index,
              selectedIndex: selectedIndex,
              title: item.title,
              icon: item.icon,
              onTap: onChanged,
            );
          }),

          const Spacer(),
          IconButton(
            icon: const Icon(FluentIcons.sign_out),
            onPressed: () {
              ref.read(authSessionProvider.notifier).clear();
              print("auth try  ${ref.read(authSessionProvider).refreshToken}");
            },
          ),
          Text(
            'v0.1',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: DesignTokens.brown),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.index,
    required this.selectedIndex,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final String title;
  final IconData icon;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Button(
        onPressed: () => onTap(index),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          backgroundColor: WidgetStateProperty.all(
            selected ? DesignTokens.brown : Colors.transparent,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: selected
                  ? BorderSide.none
                  : BorderSide(color: DesignTokens.brown, width: 1),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? DesignTokens.beige : DesignTokens.brown,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 10.w),

            // ✅ هنا بقى الأيقونة بتتغير حسب اللي بتمره فوق
            Icon(
              icon,
              color: selected ? DesignTokens.beige : DesignTokens.brown,
            ),
          ],
        ),
      ),
    );
  }
}
