import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/design_tokens.dart';
import '../../features/notifications/presentation/viewmodel/notifications_vm.dart';
import '../../features/notifications/presentation/widgets/notifications_flyout.dart';

class TopBar extends ConsumerStatefulWidget {
  const TopBar({super.key, required this.pageTitle, this.onBellTap});

  final String pageTitle;
  final VoidCallback? onBellTap;

  @override
  ConsumerState<TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<TopBar> {
  final _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsVmProvider);

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
                    widget.pageTitle,
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
                  child: FlyoutTarget(
                    controller: _flyoutController,
                    child: IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            FluentIcons.ringer,
                            size: 18.sp,
                            color: DesignTokens.brown,
                          ),
                          if (notificationsState.unreadCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: InfoBadge(
                                source: Text('${notificationsState.unreadCount}'),
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        widget.onBellTap?.call();
                        _flyoutController.showFlyout(
                          builder: (context) => const NotificationsFlyout(),
                          barrierDismissible: true,
                          dismissWithEsc: true,
                        );
                      },
                    ),
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
