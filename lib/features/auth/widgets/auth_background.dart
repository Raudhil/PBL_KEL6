import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jawara/theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  final AnimationController? animationController;
  final bool withWave;

  const AuthBackground({
    super.key,
    this.animationController,
    this.withWave = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left animated circle with pulse
        Positioned(top: -50, left: -50, child: _buildPulsingCircle()),

        if (withWave)
          // Top wave decoration
          Positioned(top: 0, left: 0, right: 0, child: _buildWave(context)),

        // Top-right floating dots
        Positioned(top: 100, right: 20, child: _buildFloatingDots()),

        // Bottom-right circle with glow
        Positioned(bottom: -80, right: -80, child: _buildBottomCircle()),

        // Middle floating circle with rotation
        if (animationController != null)
          Positioned(top: 150, right: 30, child: _buildRotatingCircle()),

        // Small accent circle at top
        Positioned(top: 80, left: 60, child: _buildAccentCircle()),
      ],
    );
  }

  Widget _buildPulsingCircle() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2000),
      builder: (context, double value, child) {
        if (animationController != null) {
          return AnimatedBuilder(
            animation: animationController!,
            builder: (context, child) {
              final pulseValue = 1 + (0.05 * animationController!.value);
              return Transform.scale(
                scale: value * pulseValue,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.08),
                        AppColors.primary.withOpacity(0.03),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return Transform.scale(
          scale: value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingDots() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2500),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            children: [
              _buildFloatingDot(8, 0, value),
              const SizedBox(height: 12),
              _buildFloatingDot(6, 200, value),
              const SizedBox(height: 12),
              _buildFloatingDot(10, 400, value),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingDot(double size, int delayMs, double parentValue) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 1000 + delayMs),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.4 * value * parentValue),
                  AppColors.primary.withOpacity(0.2 * value * parentValue),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWave(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value * 0.5,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 120),
            painter: _WavePainter(animationValue: value),
          ),
        );
      },
    );
  }

  Widget _buildBottomCircle() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2000),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRotatingCircle() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2500),
      builder: (context, double value, child) {
        return AnimatedBuilder(
          animation: animationController!,
          builder: (context, child) {
            return Transform.rotate(
              angle: animationController!.value * 2 * pi,
              child: Opacity(
                opacity: value * 0.6,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAccentCircle() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2200),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value * 0.4,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
            ),
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, size.height * 0.5);

    // Create wave pattern
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.5 +
            20 *
                animationValue *
                (0.5 + 0.5 * (i / size.width)) *
                (1 + 0.5 * (sin(i / 50))),
      );
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = AppColors.primary.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.3);

    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.3 +
            15 *
                animationValue *
                (0.5 + 0.5 * (i / size.width)) *
                (1 + 0.5 * (sin(i / 40) + 0.5)),
      );
    }

    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
