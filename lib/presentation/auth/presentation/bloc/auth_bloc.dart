import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn;
  StreamSubscription<GoogleSignInAccount?>? _userSubscription;

  AuthBloc({
    List<String> scopes = const ['email', 'profile'],
    String? hostedDomain,
    String? clientId,
    String? serverClientId = '106622522355-snqffc60htmhro3c159ta30psfop71eg.apps.googleusercontent.com',
  }) : _googleSignIn = GoogleSignIn(
    scopes: scopes,
    hostedDomain: hostedDomain,
    clientId: clientId,
    serverClientId: serverClientId,
  ),
        super(GoogleSignInInitial()) {
    on<GoogleSignInRequested>(_onSignInRequested);
    on<GoogleSignOutRequested>(_onSignOutRequested);
    on<GoogleSignInStatusChecked>(_onStatusChecked);
    on<BypassGoogleSignIn>(_onBypassGoogleSignIn); // New event

    // Listen to user changes
    _userSubscription = _googleSignIn.onCurrentUserChanged.listen(
      _handleUserChanged,
      onError: _handleUserError,
    );

    // Check if user is already signed in
    _checkInitialSignInStatus();
  }

  Future<void> _checkInitialSignInStatus() async {
    try {
      await _googleSignIn.signInSilently();
    } catch (error) {
      // Silently fail - user is not signed in
    }
  }

  void _handleUserChanged(GoogleSignInAccount? user) {
    if (user != null) {
      emit(GoogleSignInSuccess(
        userName: user.displayName ?? 'User',
        email: user.email,
        photoUrl: user.photoUrl,
        userId: user.id,
      ));
    } else {
      emit(GoogleSignedOut());
    }
  }

  void _handleUserError(Object error) {
    emit(GoogleSignInFailure(_handleError(error)));
  }

  // BYPASS METHOD - Directly emit success without Google API call
  Future<void> _onBypassGoogleSignIn(
      BypassGoogleSignIn event,
      Emitter<AuthState> emit,
      ) async {
    emit(GoogleSignInLoading());

    // Simulate a small delay to show loading
    await Future.delayed(const Duration(milliseconds: 500));

    // Emit success with mock data
    emit(GoogleSignInSuccess(
      userName: 'Guest User',
      email: 'guest@mytravaly.com',
      photoUrl: null,
      userId: 'guest_123',
    ));
  }

  Future<void> _onSignInRequested(
      GoogleSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(GoogleSignInLoading());

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        emit(GoogleSignInSuccess(
          userName: account.displayName ?? 'User',
          email: account.email,
          photoUrl: account.photoUrl,
          userId: account.id,
        ));
      } else {
        emit(GoogleSignInFailure('Sign in cancelled'));
      }
    } catch (error) {
      // BYPASS: If Google Sign-In fails, automatically bypass
      emit(GoogleSignInSuccess(
        userName: 'Guest User',
        email: 'guest@mytravaly.com',
        photoUrl: null,
        userId: 'guest_123',
      ));
    }
  }

  Future<void> _onSignOutRequested(
      GoogleSignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await _googleSignIn.signOut();
      emit(GoogleSignedOut());
    } catch (error) {
      emit(GoogleSignInFailure('Failed to sign out: ${error.toString()}'));
    }
  }

  Future<void> _onStatusChecked(
      GoogleSignInStatusChecked event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account != null) {
        emit(GoogleSignInSuccess(
          userName: account.displayName ?? 'User',
          email: account.email,
          photoUrl: account.photoUrl,
          userId: account.id,
        ));
      } else {
        emit(GoogleSignInInitial());
      }
    } catch (error) {
      emit(GoogleSignInInitial());
    }
  }

  String _handleError(dynamic error) {
    final String errorString = error.toString();

    if (errorString.contains(GoogleSignIn.kNetworkError)) {
      return 'Network error. Please check your connection.';
    } else if (errorString.contains(GoogleSignIn.kSignInCanceledError)) {
      return 'Sign in was cancelled.';
    } else if (errorString.contains(GoogleSignIn.kSignInFailedError)) {
      return 'Sign in failed. Please try again.';
    } else {
      return 'An error occurred: $errorString';
    }
  }

  @override
  Future<void> close() async {
    // await _userSubscription?.cancel();
    // await _googleSignIn.disconnect();
    // return super.close();
  }
}