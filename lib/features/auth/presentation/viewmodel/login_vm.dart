import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_providers.dart';
import '../validation/auth_validators.dart';
import 'auth_session.dart';

class LoginState {
  final String email;
  final String password;

  final String? emailError;
  final String? passwordError;

  final bool submitting;
  final String? submitError;

  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.submitting = false,
    this.submitError,
  });

  bool get isValid => emailError == null && passwordError == null;

  LoginState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool? submitting,
    String? submitError,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
      submitting: submitting ?? this.submitting,
      submitError: submitError,
    );
  }
}

class LoginVm extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setEmail(String v) {
    state = state.copyWith(email: v, emailError: null, submitError: null);
  }

  void setPassword(String v) {
    state = state.copyWith(password: v, passwordError: null, submitError: null);
  }

  bool validate() {
    final emailErr = AuthValidators.email(state.email);
    final passErr = AuthValidators.password(state.password);

    state = state.copyWith(emailError: emailErr, passwordError: passErr);

    return emailErr == null && passErr == null;
  }

  Future<void> submitLogin() async {
    if (!validate()) {
      return;
    }

    state = state.copyWith(submitting: true, submitError: null);

    try {
      final repo = ref.read(authRepoProvider);
      final result = await repo.login(
        email: state.email.trim(),
        password: state.password,
      );

      ref
          .read(authSessionProvider.notifier)
          .setSession(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            userId: result.userId,
            role: result.role,
            userName: result.userName,
          );

      state = state.copyWith(submitting: false);
    } catch (e) {
      state = state.copyWith(submitting: false, submitError: e.toString());
    }
  }
}

final loginVmProvider = NotifierProvider<LoginVm, LoginState>(LoginVm.new);
