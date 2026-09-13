import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../core/network/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

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
  }) async {
    state = state.copyWith(authState: AuthState.loading, error: '');
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
    state = state.copyWith(authState: AuthState.loading, error: '');
    try {
      final result = await _authService.verifyOtp(
        identifier: identifier,
        code: code,
        purpose: purpose,
      );
      if (result.user != null) {
        state = state.copyWith(
          authState: AuthState.authenticated,
          user: result.user,
        );
        return true;
      }
      // Verified but no user (pre-registration)
      state = state.copyWith(authState: AuthState.unauthenticated);
      return result.verified;
    } on ApiException catch (e) {
      state = state.copyWith(
        authState: AuthState.unauthenticated,
        error: e.firstError,
      );
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authService.me();
      state = state.copyWith(user: user, authState: AuthState.authenticated);
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
    } finally {
      state = const AuthStateData(authState: AuthState.unauthenticated);
    }
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
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
