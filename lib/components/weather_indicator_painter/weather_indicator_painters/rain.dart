import 'dart:math';
import 'package:flutter/material.dart';
import '../globals.dart';

class Rain extends StatefulWidget {
  final bool day;
  final bool animation;
  const Rain(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _RainState();
}

class _RainState extends State<Rain> with SingleTickerProviderStateMixin {
  late final Animation<double> _rainAnimation;
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    _rainAnimation = Tween<double>(
      begin: -Globals.dropsDistance + Globals.startRainFrom,
      end: 0 + Globals.startRainFrom,
    ).animate(_controller);

    if (widget.animation) {
      _controller.repeat();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RainCustomPainter(widget.day, _rainAnimation.value),
          willChange: true,
          isComplex: true,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _RainCustomPainter extends CustomPainter {
  final double _rainAnimationValue;
  final bool day;
  _RainCustomPainter(this.day, this._rainAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    rain(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void rain(Canvas canvas) {
    //canvas.scale(0.95);
    canvas.translate(-10, -30); // x=0
    drawRain(canvas);

    canvas.translate(0, 5);
    fewClouds(canvas);
  }

  void drawRain(Canvas canvas, [Offset offset = const Offset(0, 0)]) {
    canvas.save();

    const double dropsHeight = 6; // 6
    const int dropsNumber = 6; // 6
    const double rainDegree = 100; // 100
    const double rainRadian = (rainDegree * pi) / 180;
    const double rainsDistance = 10; // 10
    const double rainsNumber = 10; // 10

    Offset rainOffset = const Offset(-5, 52) +
        Offset.fromDirection(rainRadian, /*Height:*/ _rainAnimationValue);

    canvas.translate(offset.dx + rainOffset.dx, offset.dy + rainOffset.dy);

    Paint paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    Offset lineOffset = const Offset(-((rainsNumber * rainsDistance) / 2), 0);
    double rainYChanges = -5;

    for (int j = 0; j < rainsNumber; j++) {
      lineOffset = Offset(lineOffset.dx + rainsDistance, lineOffset.dy) +
          // Add rainYChanges :
          Offset.fromDirection(rainRadian, rainYChanges);
      rainYChanges = -rainYChanges;
      for (int i = 0; i < dropsNumber; i++) {
        canvas.drawLine(
          Offset.fromDirection(rainRadian, (i * Globals.dropsDistance)) +
              lineOffset,
          Offset.fromDirection(
                  rainRadian, (i * Globals.dropsDistance) + dropsHeight) +
              lineOffset,
          paint,
        );
      }
    }

    canvas.restore();
  }

  void fewClouds(Canvas canvas) {
    canvas.scale(1.15);

    drawSun(canvas);
    drawCloud(canvas);
  }

  void drawSun(Canvas canvas) {
    canvas.drawCircle(
      const Offset(40, -14),
      40,
      day ? Globals.sunPaint : Globals.moonPaint,
    );
  }

  void drawCloud(Canvas canvas) {
    canvas.translate(-39.0, 42);

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    canvas.drawPath(path, Globals.cloudPaint1);
  }
}
