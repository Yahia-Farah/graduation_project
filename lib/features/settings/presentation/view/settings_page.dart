import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/design_tokens.dart';
import '../../../auth/presentation/viewmodel/auth_session.dart';
import '../viewmodel/settings_viewmodel.dart';
import '../../../../core/utils/arabic_numbers_extension.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsVmProvider.notifier).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TabView(
        currentIndex: currentIndex,
        onChanged: (index) => setState(() => currentIndex = index),
        closeButtonVisibility: CloseButtonVisibilityMode.never,
        tabs: [
          Tab(
            text: Text('البيانات الشخصية', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            icon: const Icon(FluentIcons.contact_info),
            body: const ProfileTab(),
          ),
          // Can add more tabs here if needed
        ],
      ),
    );
  }
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsVmProvider);

    if (state.isLoading) {
      return const Center(child: ProgressRing());
    }

    if (state.error != null) {
      return Center(child: Text('حدث خطأ: ${state.error}'));
    }

    final profile = state.profile;
    
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الحساب',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: DesignTokens.brown,
            ),
          ),
          SizedBox(height: 24.h),
          if (profile != null) ...[
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: DesignTokens.brown.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _ProfileItem(label: 'الاسم الأول', value: profile.firstName),
                  _ProfileItem(label: 'الاسم الأخير', value: profile.lastName),
                  _ProfileItem(label: 'البريد الإلكتروني', value: profile.email),
                  _ProfileItem(label: 'العمر', value: profile.age.toString().toArabicNumbers()),
                  if (profile.court != null) 
                    _ProfileItem(label: 'المحكمة', value: profile.court!),
                  _ProfileItem(label: 'الحالة', value: profile.isActive ? 'نشط' : 'غير نشط'),
                  _ProfileItem(label: 'عدد القضايا المسندة', value: profile.assignedCasesCount.toString().toArabicNumbers()),
                  if (profile.isApproved != null)
                    _ProfileItem(label: 'تمت الموافقة', value: profile.isApproved! ? 'نعم' : 'لا'),
                ],
              ),
            ),
          ] else ...[
            const Center(child: Text('لا يوجد بيانات متاحة')),
          ],
          const Spacer(),
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red.darker),
              ),
              onPressed: () {
                ref.read(authSessionProvider.notifier).clear();
              },
              child: Text(
                'تسجيل الخروج',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                color: DesignTokens.gray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: DesignTokens.brown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
