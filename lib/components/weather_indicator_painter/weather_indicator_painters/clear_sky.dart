import 'dart:math';

import 'package:flutter/material.dart';
import '../globals.dart';

class ClearSky extends StatefulWidget {
  final bool day;
  final bool animation;
  const ClearSky(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _ClearSkyState();
}

class _ClearSkyState extends State<ClearSky>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _animation;
  AnimationController? _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1750,
      ),
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );

    if (widget.animation) {
      _controller!.repeat(reverse: true);
    } else {
      _controller!.value = 0.5;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ClearSkyCustomPainter(
            animationValue: _animation.value,
            day: widget.day,
          ),
          willChange: true,
          isComplex: true,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class _ClearSkyCustomPainter extends CustomPainter {
  final double animationValue;
  final bool day;

  _ClearSkyCustomPainter({
    required this.animationValue,
    required this.day,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    if (day) {
      drawSun(canvas);
    } else {
      drawMoon(canvas);
    }
  }

  void drawSun(Canvas canvas) {
    canvas.drawCircle(
      const Offset(0, 0),
      50,
      Globals.sunPaint,
    );
  }

  void drawMoon(Canvas canvas) {
    final double slope = -1.5 +
        Tween<double>(
          begin: -0.1,
          end: 0.1,
        ).transform(
          animationValue,
        );

    const double magnitude = 1.0;
    const double radius = 55;
    const double innerRadius = 40;

    final startOffset = Offset.fromDirection(
      slope - pi + magnitude,
      radius,
    );

    final path = Path()
      ..moveTo(startOffset.dx, startOffset.dy)
      ..arcToPoint(
        Offset.fromDirection(slope, radius),
        radius: const Radius.circular(radius),
        clockwise: false,
        largeArc: true,
      )
      ..arcToPoint(
        startOffset,
        radius: const Radius.circular(innerRadius),
        clockwise: true,
      );

    canvas.drawPath(
      path,
      Globals.moonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ClearSkyCustomPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.day != day;
  }
}
