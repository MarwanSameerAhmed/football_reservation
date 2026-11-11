import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../extensions/context_extensions.dart';

/// The Signature Action / Swipe Button from the reference design.
///
/// Features a dark capsule track, bold white typography,
/// and a prominent vivid turf-green circular thumb with an arrow.
/// Supports both:
/// 1. True interactive swiping (سحب للتأكيد): dragging the thumb across the track.
/// 2. Tap-to-confirm: smoothly animates the slide and confirms.
class KickoffActionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? customIcon;
  final double? height;
  final Color? backgroundColor;
  final Color? circleColor;

  const KickoffActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.customIcon,
    this.height,
    this.backgroundColor,
    this.circleColor,
  });

  @override
  State<KickoffActionButton> createState() => _KickoffActionButtonState();
}

class _KickoffActionButtonState extends State<KickoffActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late Animation<double> _slideAnimation;
  double _dragPosition = 0.0;
  bool _isDragging = false;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animController.addListener(() {
      setState(() {
        _dragPosition = _slideAnimation.value;
      });
    });
  }

  @override
  void didUpdateWidget(covariant KickoffActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && oldWidget.isLoading) {
      _resetPosition();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _resetPosition() {
    _confirmed = false;
    _slideAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0.0);
  }

  void _completeSlide(double maxDrag) {
    _confirmed = true;
    _slideAnimation = Tween<double>(begin: _dragPosition, end: maxDrag).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0.0).then((_) {
      HapticFeedback.mediumImpact();
      if (widget.onPressed != null && mounted) {
        widget.onPressed!();
      }
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && !_confirmed) {
          _resetPosition();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.colorScheme;
    final defaultBg = isDark ? cs.surfaceContainerHigh : AppColors.darkSlate;
    final effectiveBg = widget.backgroundColor ?? defaultBg;

    final defaultCircle = isDark
        ? AppColors.turfGreenNeon
        : AppColors.primaryEmerald;
    final effectiveCircle = widget.circleColor ?? defaultCircle;

    final double effectiveHeight =
        widget.height ??
        context.responsive<double>(standard: 54.0, compact: 50.0, tablet: 58.0);

    final double thumbSize = effectiveHeight - 8.0;

    return Semantics(
      button: true,
      enabled: widget.onPressed != null && !widget.isLoading,
      label: widget.label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final maxDrag = (totalWidth - thumbSize - 8.0).clamp(
            0.0,
            double.infinity,
          );

          final progress = maxDrag > 0
              ? (_dragPosition / maxDrag).clamp(0.0, 1.0)
              : 0.0;

          return Container(
            height: effectiveHeight,
            width: totalWidth,
            decoration: BoxDecoration(
              color: widget.onPressed == null
                  ? effectiveBg.withValues(alpha: 0.5)
                  : effectiveBg,
              borderRadius: BorderRadius.circular(effectiveHeight / 2),
              border: Border.all(
                color: isDark ? cs.outlineVariant : const Color(0xFF23372E),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.darkSlate)
                      .withValues(alpha: isDark ? 0.35 : 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Animated green fill behind thumb as it slides
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _dragPosition + thumbSize + 4.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: effectiveCircle.withValues(
                        alpha: 0.18 + (progress * 0.25),
                      ),
                      borderRadius: BorderRadius.circular(effectiveHeight / 2),
                    ),
                  ),
                ),

                // Center Text Label
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: thumbSize + 8),
                    child: Center(
                      child: Opacity(
                        opacity: (1.0 - (progress * 0.65)).clamp(0.2, 1.0),
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: context.responsive(
                              standard: 15.0,
                              compact: 13.5,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                // Draggable / Tapable Green Circular Thumb
                Positioned(
                  left: 4.0 + _dragPosition,
                  child: GestureDetector(
                    onHorizontalDragStart: (_) {
                      if (widget.onPressed == null || widget.isLoading) return;
                      _isDragging = true;
                      _animController.stop();
                    },
                    onHorizontalDragUpdate: (details) {
                      if (widget.onPressed == null || widget.isLoading) return;
                      setState(() {
                        _dragPosition = (_dragPosition + details.delta.dx)
                            .clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (widget.onPressed == null || widget.isLoading) return;
                      _isDragging = false;
                      if (_dragPosition >= maxDrag * 0.65) {
                        _completeSlide(maxDrag);
                      } else {
                        _resetPosition();
                      }
                    },
                    onTap: () {
                      if (widget.onPressed == null ||
                          widget.isLoading ||
                          _isDragging) {
                        return;
                      }
                      // Tapping also slides smoothly and confirms
                      _completeSlide(maxDrag);
                    },
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: effectiveCircle,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: effectiveCircle.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: widget.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                ),
                              )
                            : Icon(
                                widget.customIcon ??
                                    (progress > 0.85
                                        ? Icons.check_rounded
                                        : (context.isRtl
                                              ? Icons.chevron_right_rounded
                                              : Icons.chevron_right_rounded)),
                                color: Colors.black,
                                size: 26,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
