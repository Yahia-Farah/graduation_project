import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/user_role.dart';
import '../../domain/user_entity.dart';
import '../viewmodel/judges_viewmodel.dart';

class AddUserDialog extends ConsumerStatefulWidget {
  const AddUserDialog({super.key});

  @override
  ConsumerState<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddUserDialog> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _courtCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('إضافة مستخدم جديد', style: TextStyle()),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: 'الاسم الأول',
                      child: TextBox(
                        controller: _firstNameCtrl,
                        placeholder: 'الاسم الأول',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InfoLabel(
                      label: 'الاسم والأخير',
                      child: TextBox(
                        controller: _lastNameCtrl,
                        placeholder: 'الاسم الأخير',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoLabel(
                label: 'البريد الإلكتروني',
                child: TextBox(
                  controller: _emailCtrl,
                  placeholder: 'test@example.com',
                ),
              ),
              const SizedBox(height: 12),
              InfoLabel(
                label: 'كلمة المرور',
                child: TextBox(
                  controller: _passwordCtrl,
                  obscureText: true,
                  placeholder: 'كلمة المرور',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: 'العمر',
                      child: TextBox(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        placeholder: '30',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: InfoLabel(
                      label: 'الرقم القومي',
                      child: TextBox(
                        controller: _nationalIdCtrl,
                        keyboardType: TextInputType.number,
                        placeholder: '29000000000000',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InfoLabel(
                label: 'المحكمة',
                child: TextBox(
                  controller: _courtCtrl,
                  placeholder: 'النقض / الجنايات',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: const Text('إلغاء'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: () {
            final newUser = UserEntity(
              id: '',
              firstName: _firstNameCtrl.text.trim(),
              lastName: _lastNameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
              age: int.tryParse(_ageCtrl.text) ?? 30,
              nationalId: _nationalIdCtrl.text.trim(),
              court: _courtCtrl.text.trim(),
              role: 'JUDGE',
              isActive: true,
              assignedCasesCount: 0,
              isApproved: true,
            );
            // Fire and forget — list will show ProgressRing immediately
            ref.read(judgesViewModelProvider.notifier).addUser(newUser);
            // Close dialog right away
            Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
