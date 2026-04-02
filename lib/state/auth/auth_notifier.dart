import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AppAuthState> {
  AuthNotifier() : super(const AppAuthState()) {
    _load();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        final user = session.user;
        final metadata = user.userMetadata ?? {};
        state = AppAuthState(
          isLoggedIn: true,
          userId: user.id,
          email: user.email,
          nickname: metadata['nickname'] as String?,
        );
      } else {
        state = const AppAuthState();
      }
    });
  }

  void _load() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final user = session.user;
      final metadata = user.userMetadata ?? {};
      state = AppAuthState(
        isLoggedIn: true,
        userId: user.id,
        email: user.email,
        nickname: metadata['nickname'] as String?,
      );
    }
  }

  Future<void> signUp(String email, String password) async {
    final res = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user != null) {
      state = AppAuthState(
        isLoggedIn: true,
        userId: user.id,
        email: user.email,
        nickname: null,
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    final res = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user != null) {
      final metadata = user.userMetadata ?? {};
      state = AppAuthState(
        isLoggedIn: true,
        userId: user.id,
        email: user.email,
        nickname: metadata['nickname'] as String?,
      );
    }
  }

  Future<void> setNickname(String nickname) async {
    // Update local state first so UI can proceed regardless of network
    state = state.copyWith(nickname: nickname);
    // Best-effort persist to Supabase user_metadata
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'nickname': nickname}),
      );
    } catch (_) {
      // Nickname saved in local state; will sync on next successful session
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AppAuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>(
  (ref) => AuthNotifier(),
);
