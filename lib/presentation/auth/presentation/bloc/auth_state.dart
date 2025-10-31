abstract class AuthState {}

class GoogleSignInInitial extends AuthState {}

class GoogleSignInLoading extends AuthState {}

class GoogleSignInSuccess extends AuthState {
  final String userName;
  final String email;
  final String? photoUrl;
  final String userId;

  GoogleSignInSuccess({
    required this.userName,
    required this.email,
    this.photoUrl,
    required this.userId,
  });
}

class GoogleSignInFailure extends AuthState {
  final String error;

  GoogleSignInFailure(this.error);
}

class GoogleSignedOut extends AuthState {}