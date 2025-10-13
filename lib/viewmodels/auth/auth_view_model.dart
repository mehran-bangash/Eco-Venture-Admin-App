import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/auth_repo.dart';
import 'auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepo _repo;

  AuthViewModel(this._repo) : super(AuthState.initial());

  Future<void> signInUser(
    String email,
    String password, {
    Function? onSuccess,
  }) async {
    state = state.copyWith(isEmailLoading: true, emailError: null);

    try {
      final user = await _repo.loginAdmin(email, password);

      // If login failed, throw error
      if (user == null) {
        throw Exception("Invalid email or password");
      }

      //  Only update state and call onSuccess when login succeeds
      state = state.copyWith(isEmailLoading: false, admin: user);

      await SharedPreferencesHelper.instance.saveAdminId(user.uid);
      await SharedPreferencesHelper.instance.saveAdminName(user.name);
      await SharedPreferencesHelper.instance.saveAdminEmail(user.email);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(isEmailLoading: false, emailError: e.toString());
    }
  }

  Future<void> forgotPassword(String email, {Function? onSuccess}) async {
    state = state.copyWith(isEmailLoading: true, emailError: null);
    try {
      await _repo.forgotPassword(email);
      state = state.copyWith(isEmailLoading: false);

      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(isEmailLoading: false, emailError: e.toString());
    }
  }
}
