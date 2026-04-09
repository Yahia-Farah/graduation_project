import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/design_tokens.dart';
import '../../domain/user_entity.dart';
import '../viewmodel/users_viewmodel.dart';
import 'add_user_dialog.dart';

class UsersManagementPage extends ConsumerWidget {
  const UsersManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersViewModelProvider);

    return ScaffoldPage(
      header: const PageHeader(
        title: Text(
          'إدارة المستخدمين',
          style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold),
        ),
      ),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Toolbar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'قائمة المستخدمين في النظام',
                    style: TextStyle(fontSize: 16),
                  ),
                  FilledButton(
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.add, size: 14),
                        SizedBox(width: 8),
                        Text('إضافة مستخدم جديد'),
                      ],
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddUserDialog(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Data View
              Expanded(
                child: state.when(
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(child: Text('لا يوجد مستخدمين'));
                    }
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return _buildUserCard(context, ref, users[index]);
                      },
                    );
                  },
                  loading: () => const Center(child: ProgressRing()),
                  error: (e, st) => Center(child: Text('حدث خطأ: \$e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, UserEntity user) {
    final bool isAdmin = user.role.toUpperCase() == 'ADMIN';
    final Color roleColor = isAdmin ? DesignTokens.green : DesignTokens.brown;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DesignTokens.beige,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                FluentIcons.contact,
                size: 24,
                color: DesignTokens.brown,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(FluentIcons.mail, size: 12),
                      const SizedBox(width: 4),
                      Text(user.email, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                      const Icon(FluentIcons.entitlement_policy, size: 12),
                      const SizedBox(width: 4),
                      Text(user.court.isEmpty ? 'غير محدد' : user.court, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: roleColor),
              ),
              child: Text(
                user.role,
                style: TextStyle(
                  color: roleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ToggleSwitch(
              checked: user.isActive,
              content: const Text('نشط'),
              onChanged: (v) {
                ref
                    .read(usersViewModelProvider.notifier)
                    .toggleUserStatus(user);
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(FluentIcons.delete, color: Colors.red),
              onPressed: () {
                _confirmDelete(context, ref, user);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) {
        return ContentDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف المستخدم \${user.fullName}؟'),
          actions: [
            Button(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(ctx),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.red),
              ),
              onPressed: () {
                ref.read(usersViewModelProvider.notifier).deleteUser(user.id);
                Navigator.pop(ctx);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}
