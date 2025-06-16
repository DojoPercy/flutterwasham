import 'package:WashAm/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../common_blocs/auth/auth_bloc.dart';
import '../../common_blocs/auth/auth_events.dart';
import '../../common_blocs/auth/auth_state.dart';

class SafeOnTap {
  DateTime? _lastTapTime;

  void execute(
      {required BuildContext context, required VoidCallback onSafeTap}) {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(milliseconds: 700)) {
      _lastTapTime = now;
      onSafeTap();
    } else {
      Message.infoMessage(
        context: context,
        title: "Too Fast!",
        content: "Please wait a moment before tapping again.",
      );
    }
  }
}

class Message {
  static void errorMessage({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    _showMessage(
        context, title, content, Colors.red.shade700, LucideIcons.xCircle);
  }

  static void infoMessage({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    _showMessage(
        context, title, content, Colors.blue.shade700, LucideIcons.info);
  }

  static void _showMessage(BuildContext context, String title, String content,
      Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late VideoPlayerController _videoController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _videoController =
        VideoPlayerController.asset('assets/videos/washamvid.mp4')
          ..setLooping(true)
          ..setVolume(0)
          ..initialize().then((_) {
            setState(() {});
            _videoController.play();
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _handleAuthStates(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
    } else if (state is AuthSuccess) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).hideCurrentSnackBar();
      Message.infoMessage(
        context: _scaffoldKey.currentContext!,
        title: 'Login Successful',
        content: 'Welcome back!',
      );
      AppRouter().push(context, '/home');
    } else if (state is AuthFailure) {
      Message.errorMessage(
        context: _scaffoldKey.currentContext!,
        title: "Login Failed",
        content: state.message,
      );
    } else if (state is AuthNewUser) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).hideCurrentSnackBar();
      Message.infoMessage(
        context: _scaffoldKey.currentContext!,
        title: 'New User Detected',
        content: 'Please complete your registration.',
      );

      AppRouter().push(context, '/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleAuthStates,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            _videoController.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                : Container(color: Colors.black),
            const _VideoOverlay(),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo3.png',
                height: 80,
              )
                  .animate()
                  .fade(duration: 800.ms)
                  .scale(begin: Offset(1, 5), duration: 800.ms),
              const SizedBox(height: 24),
              const Text(
                "Your Laundry, Simplified.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black38,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fade(duration: 800.ms, delay: 200.ms)
                  .slideY(begin: 0.1, duration: 800.ms, delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                "Experience premium, on-demand laundry and dry cleaning services right at your fingertips.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
              )
                  .animate()
                  .fade(duration: 800.ms, delay: 400.ms)
                  .slideY(begin: 0.1, duration: 800.ms, delay: 400.ms),
              const SizedBox(height: 40),
              _GoogleSignInButton(
                onPressed: () {
                  SafeOnTap().execute(
                    context: context,
                    onSafeTap: () {
                      context.read<AuthBloc>().add(SignInWithGoogleRequested());
                    },
                  );
                },
              )
                  .animate()
                  .fade(duration: 800.ms, delay: 600.ms)
                  .slideY(begin: 0.1, duration: 800.ms, delay: 600.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoOverlay extends StatelessWidget {
  const _VideoOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B3A6B).withOpacity(0.9),
            const Color(0xFF1B3A6B).withOpacity(0.7),
            Colors.transparent,
            const Color(0xFF1B3A6B).withOpacity(0.9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A2A4A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        icon: Image.asset(
          'assets/images/google_icon.png',
          height: 28,
        ),
        label: const Text(
          "Continue with Google",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
