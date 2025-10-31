abstract class AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class GoogleSignOutRequested extends AuthEvent {}

class GoogleSignInStatusChecked extends AuthEvent {}

class BypassGoogleSignIn extends AuthEvent {}