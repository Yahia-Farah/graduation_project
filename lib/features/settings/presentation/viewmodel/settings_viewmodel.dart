import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profile_model.dart';
import '../../data/settings_repository.dart';
import '../../../auth/presentation/viewmodel/user_role_provider.dart';

class SettingsState {
  final bool isLoading;
  final ProfileData? profile;
  final String? error;

  SettingsState({this.isLoading = false, this.profile, this.error});

  SettingsState copyWith({bool? isLoading, ProfileData? profile, String? error}) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error ?? this.error,
    );
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() => SettingsState();

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final role = ref.read(userRoleProvider);
      final profile = await ref.read(settingsRepositoryProvider).getProfile(role);
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final settingsVmProvider = NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
