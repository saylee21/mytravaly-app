import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../hotels/presentation/home_page.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_state.dart';
import 'bloc/auth_event.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        serverClientId: '106622522355-snqffc60htmhro3c159ta30psfop71eg.apps.googleusercontent.com',
      ),
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is GoogleSignInSuccess) {
              // Navigate to Home Page
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            } else if (state is GoogleSignInFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: const Color(0xFFFF7B6D),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF9A8B),
                    Color(0xFFFF7B6D),
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: _buildMobileLayout(context, state),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AuthState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: _buildContent(context, state),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFF7B6D).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.flight_takeoff,
            size: 40,
            color: Color(0xFFFF7B6D),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'MyTravaly',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your travel companion',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 48),
        const Text(
          'Welcome Back!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to explore amazing hotels',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 40),
        if (state is GoogleSignInLoading)
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF7B6D),
            ),
          )
        else
          _buildSignInButtons(context),
        const SizedBox(height: 28),
        Text(
          'By continuing, you agree to our\nTerms of Service and Privacy Policy',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButtons(BuildContext context) {
    return Column(
      children: [
        // Google Sign In Button
        ElevatedButton.icon(
          onPressed: () {
            context.read<AuthBloc>().add(GoogleSignInRequested());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D3748),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            elevation: 0,
          ),
          icon: Image.network(
            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.g_mobiledata, size: 28);
            },
          ),
          label: const Text(
            'Sign in with Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bypass Button (Guest Mode)
        ElevatedButton.icon(
          onPressed: () {
            context.read<AuthBloc>().add(BypassGoogleSignIn());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7B6D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.arrow_forward, size: 22),
          label: const Text(
            'Continue as Guest',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}