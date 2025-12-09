import 'package:flutter/material.dart';
import 'package:jawara/theme/app_colors.dart';
import 'dart:math' as math;

class LandscapeHeader extends StatefulWidget {
  const LandscapeHeader({super.key});

  @override
  State<LandscapeHeader> createState() => _LandscapeHeaderState();
}

class _LandscapeHeaderState extends State<LandscapeHeader>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _balloonController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _balloonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _balloonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primary400],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Animated clouds
          AnimatedBuilder(
            animation: _cloudController,
            builder: (context, child) {
              return Positioned(
                top: 30,
                left:
                    -100 +
                    (_cloudController.value *
                        MediaQuery.of(context).size.width *
                        1.5),
                child: _buildCloud(40, 20),
              );
            },
          ),
          AnimatedBuilder(
            animation: _cloudController,
            builder: (context, child) {
              return Positioned(
                top: 60,
                left:
                    -80 +
                    (_cloudController.value *
                        MediaQuery.of(context).size.width *
                        1.3),
                child: _buildCloud(30, 15),
              );
            },
          ),

          // Mountains
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 120),
              painter: _MountainPainter(),
            ),
          ),

          // Animated balloon
          AnimatedBuilder(
            animation: _balloonController,
            builder: (context, child) {
              return Positioned(
                top: 40 + (_balloonController.value * 20),
                right: 40,
                child: _buildBalloon(),
              );
            },
          ),

          // Windmills
          Positioned(bottom: 40, right: 60, child: _buildWindmill()),
          Positioned(
            bottom: 40,
            right: 100,
            child: Transform.scale(scale: 0.8, child: _buildWindmill()),
          ),

          // Houses
          Positioned(bottom: 35, left: 40, child: _buildHouse()),
          Positioned(
            bottom: 35,
            left: 100,
            child: Transform.scale(
              scale: 0.7,
              child: _buildHouse(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildBalloon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.warning,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        Container(width: 1, height: 15, color: Colors.white.withOpacity(0.6)),
      ],
    );
  }

  Widget _buildWindmill() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _cloudController,
          child: Container(
            width: 20,
            height: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                ...List.generate(
                  3,
                  (index) => Transform.rotate(
                    angle: (index * 2 * math.pi) / 3,
                    child: Container(
                      width: 2,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 3,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildHouse({Color color = AppColors.primary100}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Roof
        CustomPaint(size: const Size(25, 12), painter: _RoofPainter()),
        // House body
        Container(
          width: 20,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(2),
              bottomRight: Radius.circular(2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary700.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppColors.primary700.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = AppColors.primary600.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = AppColors.primary500.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Back mountain
    final path3 = Path();
    path3.moveTo(0, size.height);
    path3.lineTo(0, size.height * 0.4);
    path3.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.1,
      size.width * 0.35,
      size.height * 0.3,
    );
    path3.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.45,
      size.width * 0.7,
      size.height * 0.2,
    );
    path3.quadraticBezierTo(
      size.width * 0.85,
      0,
      size.width,
      size.height * 0.3,
    );
    path3.lineTo(size.width, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);

    // Middle mountain
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.4,
    );
    path2.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.6,
      size.width,
      size.height * 0.5,
    );
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Front mountain/hills
    final path1 = Path();
    path1.moveTo(0, size.height);
    path1.lineTo(0, size.height * 0.7);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.65,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.7,
    );
    path1.lineTo(size.width, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.danger.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
