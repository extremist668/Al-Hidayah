import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:islamic_app/services/supabase_service.dart';

enum AuthStatus { unauthenticated, authenticated, guest, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(status: AuthStatus.loading)) {
    _checkSession();
  }

  void _checkSession() {
    try {
      final hasSupabase = SupabaseService.instance.isInitialized;
      if (!hasSupabase) {
        state = AuthState(status: AuthStatus.guest);
        return;
      }

      final session = SupabaseService.instance.client.auth.currentSession;
      if (session != null) {
        state = AuthState(status: AuthStatus.authenticated, user: session.user);
      } else {
        state = AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = AuthState(status: AuthStatus.guest);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      if (!SupabaseService.instance.isInitialized) {
        throw Exception('Supabase connection offline. Please use guest mode.');
      }
      final response = await SupabaseService.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: e.message);
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: e.toString());
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      if (!SupabaseService.instance.isInitialized) {
        throw Exception('Supabase connection offline. Please use guest mode.');
      }
      final response = await SupabaseService.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: e.message);
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: e.toString());
    }
  }

  void continueAsGuest() {
    state = AuthState(status: AuthStatus.guest);
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      if (SupabaseService.instance.isInitialized) {
        await SupabaseService.instance.client.auth.signOut();
      }
    } catch (_) {}
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
