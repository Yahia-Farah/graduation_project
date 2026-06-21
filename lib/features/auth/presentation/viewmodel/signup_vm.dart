import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_providers.dart';
import '../validation/auth_validators.dart';

class SignupState {
  final String firstName;
  final String lastName;
  final String email;
  final String nationalId;
  final String password;
  final String confirmPassword;

  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? nationalIdError;
  final String? passwordError;
  final String? confirmPasswordError;

  final bool submitting;
  final bool isSuccess;
  final String? submitError;

  const SignupState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.nationalId = '',
    this.password = '',
    this.confirmPassword = '',
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.nationalIdError,
    this.passwordError,
    this.confirmPasswordError,
    this.submitting = false,
    this.isSuccess = false,
    this.submitError,
  });

  SignupState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? nationalId,
    String? password,
    String? confirmPassword,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? nationalIdError,
    String? passwordError,
    String? confirmPasswordError,
    bool? submitting,
    bool? isSuccess,
    String? submitError,
  }) {
    return SignupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      emailError: emailError,
      nationalIdError: nationalIdError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      submitting: submitting ?? this.submitting,
      isSuccess: isSuccess ?? this.isSuccess,
      submitError: submitError,
    );
  }
}

class SignupVm extends AutoDisposeNotifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  void setFirstName(String v) => state = state.copyWith(
    firstName: v,
    firstNameError: null,
    submitError: null,
  );

  void setLastName(String v) => state = state.copyWith(
    lastName: v,
    lastNameError: null,
    submitError: null,
  );

  void setEmail(String v) =>
      state = state.copyWith(email: v, emailError: null, submitError: null);

  void setNationalId(String v) => state = state.copyWith(
    nationalId: v,
    nationalIdError: null,
    submitError: null,
  );

  void setPassword(String v) => state = state.copyWith(
    password: v,
    passwordError: null,
    submitError: null,
  );

  void setConfirmPassword(String v) => state = state.copyWith(
    confirmPassword: v,
    confirmPasswordError: null,
    submitError: null,
  );

  bool validate() {
    final fnErr = AuthValidators.requiredField(
      state.firstName,
      msg: 'الاسم الأول مطلوب',
    );
    final lnErr = AuthValidators.requiredField(
      state.lastName,
      msg: 'الاسم الأخير مطلوب',
    );
    final emailErr = AuthValidators.email(state.email);

    // رقم قومي: في مصر غالبًا 14 رقم (لو عندكم نفس القاعدة)
    final nid = state.nationalId.trim();
    String? nidErr;
    if (nid.isEmpty) {
      nidErr = 'الرقم القومي مطلوب';
    } else if (!RegExp(r'^\d{14}$').hasMatch(nid)) {
      nidErr = 'الرقم القومي يجب أن يكون 14 رقم';
    }

    final passErr = AuthValidators.password(state.password);
    final confErr = AuthValidators.confirmPassword(
      state.password,
      state.confirmPassword,
    );

    state = state.copyWith(
      firstNameError: fnErr,
      lastNameError: lnErr,
      emailError: emailErr,
      nationalIdError: nidErr,
      passwordError: passErr,
      confirmPasswordError: confErr,
    );

    return fnErr == null &&
        lnErr == null &&
        emailErr == null &&
        nidErr == null &&
        passErr == null &&
        confErr == null;
  }

  Future<void> submitSignup() async {
    if (!validate()) {
      return;
    }

    state = state.copyWith(
      submitting: true,
      submitError: null,
      isSuccess: false,
    );

    try {
      final repo = ref.read(authRepoProvider);
      await repo.signup(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        email: state.email.trim(),
        nationalId: state.nationalId.trim(),
        password: state.password,
        confirmPassword: state.confirmPassword,
      );

      // Now we just set success, which will tell the UI to jump to OTP view.
      state = state.copyWith(submitting: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        submitting: false,
        submitError: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final signupVmProvider = AutoDisposeNotifierProvider<SignupVm, SignupState>(SignupVm.new);
