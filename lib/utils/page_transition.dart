import 'package:flutter/material.dart';

class CircularRevealTransition extends PageRouteBuilder {
  final Widget page;
  final Alignment alignment;
  final Color color;
  final Duration duration;

  CircularRevealTransition({
    required this.page,
    this.alignment = Alignment.center,
    this.color = Colors.yellow,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                child,
                AnimatedBuilder(
                  animation: animation,
                  builder: (_, __) {
                    return CircularRevealClipper(
                      fraction: animation.value,
                      alignment: alignment,
                      color: color,
                    );
                  },
                ),
              ],
            );
          },
          transitionDuration: duration,
        );
}

class CircularRevealClipper extends StatelessWidget {
  final double fraction;
  final Alignment alignment;
  final Color color;

  const CircularRevealClipper({
    super.key,
    required this.fraction,
    required this.alignment,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: fraction > 0,
      child: CustomPaint(
        painter: _CircularRevealPainter(
          fraction: 1 - fraction,
          alignment: alignment,
          color: color,
        ),
        child: Container(),
      ),
    );
  }
}

class _CircularRevealPainter extends CustomPainter {
  final double fraction;
  final Alignment alignment;
  final Color color;

  _CircularRevealPainter({
    required this.fraction,
    required this.alignment,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(
      size.width * ((alignment.x * 0.5) + 0.5),
      size.height * ((alignment.y * 0.5) + 0.5),
    );
    final radius = fraction * calculateMaxDistanceToCorners(size, center);
    canvas.drawCircle(center, radius, paint);
  }

  double calculateMaxDistanceToCorners(Size size, Offset center) {
    final double diagonal = size.height * size.height + size.width * size.width;
    final double maxDistance = diagonal * 0.5;
    return maxDistance;
  }

  @override
  bool shouldRepaint(_CircularRevealPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
