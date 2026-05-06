import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthSessionState {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? role;
  final String? userName;

  const AuthSessionState({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.role,
    this.userName,
  });

  bool get isAuthed => accessToken != null && accessToken!.isNotEmpty;

  AuthSessionState copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? role,
    String? userName,
  }) {
    return AuthSessionState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      userName: userName ?? this.userName,
    );
  }

  static const empty = AuthSessionState();
}

class AuthSession extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() => AuthSessionState.empty;

  void setSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    required String userName,
  }) {
    state = AuthSessionState(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      role: role,
      userName: userName,
    );
  }

  void clear() => state = AuthSessionState.empty;
}

final authSessionProvider = NotifierProvider<AuthSession, AuthSessionState>(
  AuthSession.new,
);
