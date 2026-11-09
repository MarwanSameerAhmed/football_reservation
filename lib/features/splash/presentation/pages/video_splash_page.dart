import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

/// Full-screen Video Splash Screen.
///
/// Seamlessly continues from the native launch window with the exact same
/// background color (#F2F2E7), eliminating any screen flash or jump.
class VideoSplashPage extends StatefulWidget {
  final VoidCallback? onComplete;

  const VideoSplashPage({super.key, this.onComplete});

  @override
  State<VideoSplashPage> createState() => _VideoSplashPageState();
}

class _VideoSplashPageState extends State<VideoSplashPage> {
  static const Color _splashBgColor = Color(0xFFF2F2E7);
  static const String _videoAsset =
      'assets/splash_screen/gemini_generated_video_77849432.mp4';

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
        await _controller.play();
      }
    } catch (e) {
      debugPrint('VideoSplashPage initialization note: $e');
      // If video fails (e.g. in test environment), proceed safely
      _navigateToNext();
      return;
    }

    // Safety fallback timer matching the 10-second video duration
    _fallbackTimer = Timer(const Duration(seconds: 10, milliseconds: 500), () {
      _navigateToNext();
    });
  }

  void _navigateToNext() {
    if (_navigated) return;
    _navigated = true;
    _fallbackTimer?.cancel();
    if (widget.onComplete != null) {
      widget.onComplete!();
      return;
    }
    if (mounted) {
      try {
        context.go('/');
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
    return Scaffold(
      backgroundColor: _splashBgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToNext,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video display centered on the seamless #F2F2E7 canvas
            if (_controller.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),

            // Subtle Skip ("تخطي") pill button for optimal UX
            Positioned(
              top: MediaQuery.of(context).padding.top + 14,
              left: 16,
              child: GestureDetector(
                onTap: _navigateToNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تخطي',
                        style: TextStyle(
                          color: Color(0xFF141917),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.fast_forward_rounded,
                        size: 15,
                        color: Color(0xFF141917),
                      ),
                    ],
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
