class AppAuthState {
  final bool isLoggedIn;
  final String? userId;
  final String? email;
  final String? nickname;

  const AppAuthState({
    this.isLoggedIn = false,
    this.userId,
    this.email,
    this.nickname,
  });

  AppAuthState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? email,
    String? nickname,
  }) {
    return AppAuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
    );
  }
}
