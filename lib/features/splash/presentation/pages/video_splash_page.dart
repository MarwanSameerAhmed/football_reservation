import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

/// Full-screen Video Splash Screen.
///
/// Seamlessly continues from the native launch window with the exact same
/// background color (AppColors.canvasLight / AppColors.canvasDark), eliminating any screen flash or jump.
class VideoSplashPage extends StatefulWidget {
  final VoidCallback? onComplete;

  const VideoSplashPage({super.key, this.onComplete});

  @override
  State<VideoSplashPage> createState() => _VideoSplashPageState();
}

class _VideoSplashPageState extends State<VideoSplashPage> {
  static const String _videoAsset =
      'assets/splash_screen/gemini_generated_video_839511a5.mp4';

  late final VideoPlayerController _controller;
  bool _navigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    _controller = VideoPlayerController.asset(_videoAsset);

    _controller.addListener(() {
      if (!mounted) return;
      if (_controller.value.isInitialized &&
          _controller.value.position >= _controller.value.duration) {
        _navigateToNext();
      }
    });

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {});
        await _controller.setPlaybackSpeed(1.0);
        await _controller.play();
      }
    } catch (e) {
      debugPrint('VideoSplashPage initialization note: $e');
      // If video fails (e.g. in test environment), proceed safely
      _navigateToNext();
      return;
    }

    // Safety fallback timer matching the 6-second video duration
    _fallbackTimer = Timer(const Duration(seconds: 6, milliseconds: 200), () {
      _navigateToNext();
    });
  }

  Future<void> _navigateToNext() async {
    if (_navigated) return;
    _navigated = true;
    _fallbackTimer?.cancel();
    if (widget.onComplete != null) {
      widget.onComplete!();
      return;
    }
    if (!mounted) return;
    try {
      final authBloc = context.read<AuthBloc?>();
      if (authBloc != null) {
        var authState = authBloc.state;
        if (authState is AuthInitial || authState is AuthLoading) {
          try {
            authState = await authBloc.stream
                .firstWhere(
                  (state) => state is! AuthInitial && state is! AuthLoading,
                )
                .timeout(const Duration(seconds: 2));
          } catch (_) {
            authState = authBloc.state;
          }
        }
        if (!mounted) return;
        if (authState is Unauthenticated || authState is AuthFailureState) {
          context.go('/sign-in');
          return;
        }
      }
      if (mounted) {
        context.go('/');
      }
    } catch (_) {
      try {
        if (mounted) {
          context.go('/');
        }
      } catch (_) {
        // Safe when pumped without GoRouter in standalone tests
      }
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final effectiveBg = isDark ? AppColors.canvasDark : AppColors.canvasLight;

    return Scaffold(
      backgroundColor: effectiveBg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToNext,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video display centered with true background keying & multiply blending (no dirty vignette halo)
            if (_controller.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: ColorFiltered(
                    colorFilter: isDark
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          )
                        : ColorFilter.mode(effectiveBg, BlendMode.multiply),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        1.45,
                        0,
                        0,
                        0,
                        22,
                        0,
                        1.45,
                        0,
                        0,
                        22,
                        0,
                        0,
                        1.45,
                        0,
                        22,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
