import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../core/network/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/profile_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated }

class AuthNotifier extends StateNotifier<AuthStateData> {
  AuthNotifier() : super(const AuthStateData());

  final _authService = AuthService();

  Future<void> login({
    required String identifier,
    required String password,
    String loginContext = 'buyer',
  }) async {
    state = state.copyWith(authState: AuthState.loading, error: '');
    try {
      final result = await _authService.login(
        identifier: identifier,
        password: password,
        loginContext: loginContext,
      );
      state = state.copyWith(
        authState: AuthState.authenticated,
        user: result.user,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        authState: AuthState.unauthenticated,
        error: e.firstError,
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'buyer',
    String? companyName,
    bool activateSession = true,
  }) async {
    if (activateSession) {
      state = state.copyWith(authState: AuthState.loading, error: '');
    } else {
      // Keep the public signup guard mounted while onboarding continues.
      // The API token/user are retained, but authentication is activated only
      // after KYC, documents, and payment are complete.
      state = state.copyWith(error: '');
    }
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
        companyName: companyName,
      );
      state = state.copyWith(
        authState: activateSession
            ? AuthState.authenticated
            : AuthState.unauthenticated,
        user: result.user,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        authState: activateSession ? AuthState.unauthenticated : null,
        error: e.firstError,
      );
    }
  }

  Future<int?> requestOtp(String identifier, {String purpose = 'login'}) async {
    try {
      return await _authService.requestOtp(identifier: identifier, purpose: purpose);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.firstError);
      return null;
    }
  }

  Future<int?> resendOtp(String identifier, {String purpose = 'login'}) async {
    try {
      return await _authService.resendOtp(identifier: identifier, purpose: purpose);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.firstError);
      return null;
    }
  }

  Future<bool> verifyOtp(
    String identifier,
    String code, {
    String purpose = 'login',
  }) async {
    final isLogin = purpose == 'login';
    if (isLogin) {
      state = state.copyWith(authState: AuthState.loading, error: '');
    } else {
      // Registration OTP verification must not trigger the global auth guard;
      // otherwise the signup screen is replaced by the app loading screen.
      state = state.copyWith(error: '');
    }
    try {
      final result = await _authService.verifyOtp(
        identifier: identifier,
        code: code,
        purpose: purpose,
      );
      if (isLogin && result.user != null) {
        state = state.copyWith(
          authState: AuthState.authenticated,
          user: result.user,
        );
        return true;
      }
      // Verified but no user (pre-registration)
      if (isLogin) {
        state = state.copyWith(authState: AuthState.unauthenticated);
      }
      return result.verified;
    } on ApiException catch (e) {
      state = state.copyWith(
        authState: isLogin ? AuthState.unauthenticated : null,
        error: e.firstError,
      );
      return false;
    }
  }

  Future<void> refreshUser({bool activateSession = true}) async {
    try {
      final user = await _authService.me();
      state = state.copyWith(
        user: user,
        authState: activateSession ? AuthState.authenticated : null,
      );
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        state = const AuthStateData(authState: AuthState.unauthenticated);
      }
    }
  }

  Future<void> checkSession() async {
    final token = await TokenStorage.read();
    if (token == null) {
      state = state.copyWith(authState: AuthState.unauthenticated);
      return;
    }
    await refreshUser();
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      await BiometricService.clear();
    } finally {
      state = const AuthStateData(authState: AuthState.unauthenticated);
    }
  }

  Future<void> deleteAccount() async {
    await ProfileService().deleteAccount();
    await BiometricService.clear();
    await TokenStorage.clear();
    state = const AuthStateData(authState: AuthState.unauthenticated);
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
  }

  void setUser(AppUser user) {
    state = state.copyWith(user: user);
  }

  void clearError() {
    state = state.copyWith(error: '');
  }
}

class AuthStateData {
  final AuthState authState;
  final AppUser? user;
  final bool onboardingComplete;
  final String error;

  const AuthStateData({
    this.authState = AuthState.initial,
    this.user,
    this.onboardingComplete = false,
    this.error = '',
  });

  AuthStateData copyWith({
    AuthState? authState,
    AppUser? user,
    bool? onboardingComplete,
    String? error,
  }) => AuthStateData(
    authState: authState ?? this.authState,
    user: user ?? this.user,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    error: error ?? this.error,
  );

  bool get isAuthenticated => authState == AuthState.authenticated;
  bool get isSeller => user?.isSeller ?? false;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get hasError => error.isNotEmpty;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthStateData>(
  (ref) => AuthNotifier(),
);
