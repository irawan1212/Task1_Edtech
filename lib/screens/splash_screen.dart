import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/onboarding/onboarding_screen.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late AnimationController _revealAnimationController;
  late Animation<double> _revealAnimation;
  bool _isRevealing = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    _revealAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _revealAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _navigateToOnboarding();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _revealAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Offset bottomRightCorner = Offset(size.width, size.height);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          if (!_isRevealing) {
            _startRevealAnimation();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Static background
            Container(color: Colors.white),

            AnimatedBuilder(
              animation: _revealAnimation,
              builder: (context, child) {
                if (!_isRevealing) return const SizedBox.shrink();

                return CustomPaint(
                  size: Size.infinite,
                  painter: CircularRevealPainter(
                    color: AppTheme.primaryColor,
                    center: bottomRightCorner,
                    radius:
                        _revealAnimation.value * _calculateMaxRadius(context),
                  ),
                );
              },
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/images/cropped-Logo-US-Header-1 1.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRevealAnimation() {
    if (_isRevealing) return;

    setState(() {
      _isRevealing = true;
    });

    _revealAnimationController.reset();
    _revealAnimationController.forward();
  }

  double _calculateMaxRadius(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double maxX = size.width;
    final double maxY = size.height;
    return math.sqrt(maxX * maxX + maxY * maxY) * 1.2;
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class CircularRevealPainter extends CustomPainter {
  final Color color;
  final Offset center;
  final double radius;

  CircularRevealPainter({
    required this.color,
    required this.center,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CircularRevealPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.center != center ||
        oldDelegate.color != color;
  }
}
