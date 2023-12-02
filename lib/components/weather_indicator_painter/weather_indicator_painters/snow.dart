import 'dart:math';
import 'package:flutter/material.dart';
import '../globals.dart';

const double flakesDistance = 25; // drawSnow

class Snow extends StatefulWidget {
  final bool day;
  final bool animation;
  const Snow(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _SnowState();
}

class _SnowState extends State<Snow> with SingleTickerProviderStateMixin {
  late final Animation<double> _snowAnimation;
  late final AnimationController _controller;
  // drawRain & drawSnow

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _snowAnimation = Tween<double>(
            begin: -flakesDistance + Globals.startSnowFrom,
            end: Globals.startSnowFrom)
        .animate(_controller)
      ..drive(CurveTween(curve: Curves.easeInCirc))
      ..addListener(() => setState(() {}))
      ..addStatusListener(
        (AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            _controller.repeat();
          } else if (status == AnimationStatus.dismissed) {
            _controller.forward();
          }
        },
      );

    if (widget.animation) _controller.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _SnowCustomPainter(widget.day, _snowAnimation.value),
        willChange: true,
        isComplex: true,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SnowCustomPainter extends CustomPainter {
  final double _snowAnimationValue;
  final bool day;
  _SnowCustomPainter(this.day, this._snowAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    snow(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void snow(Canvas canvas) {
    canvas.scale(1.05); // test
    canvas.translate(-12, -25); // x=0, y=-30
    drawSnow(canvas);

    drawCloud(canvas,
        offset: const Offset(30, -20),
        scale: 0.9,
        color: const Color.fromARGB(255, 100, 100, 100));

    drawCloud(canvas);
  }

  void drawSnowFlake(Canvas canvas, Offset offset) {
    const double scale = 1.1; // 1.1
    const int linesNumber = 6; // 6
    const double linesLenght = 6.1 * scale; // 6.1
    const double sublinesLenght = 3 * scale; // 3
    const double sublinesStartRadius = linesLenght / 2; // 3.25
    const double sublinesAngle = 40; // 40
    const double circleRadius = 1.2 * scale; // 1.2

    Paint paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.white.withAlpha(255) // 230
      ..strokeWidth = 0.5 * (scale * 1.5) // 0.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(offset, circleRadius, paint);

    double angleCache = (pi * 2) / linesNumber;

    for (int i = 0; i < linesNumber; i++) {
      double lineAngle = angleCache * i;
      canvas.drawLine(offset + Offset.fromDirection(lineAngle, circleRadius),
          offset + Offset.fromDirection(lineAngle, linesLenght), paint);

      Offset sublinesOffset1 =
          Offset.fromDirection(lineAngle, sublinesStartRadius) + offset;
      double sublineAngle = ((sublinesAngle * pi) / 180);

      canvas.drawLine(
          sublinesOffset1,
          sublinesOffset1 +
              Offset.fromDirection(lineAngle + sublineAngle, sublinesLenght),
          paint);
      canvas.drawLine(
          sublinesOffset1,
          sublinesOffset1 +
              Offset.fromDirection(lineAngle - sublineAngle, sublinesLenght),
          paint);
    }
  }

  void drawSnow(Canvas canvas, {Offset offset = const Offset(0, 0)}) {
    canvas.save();
    canvas.scale(0.95);

    const int flakesNumber = 5;
    const double snowDegree = 100;
    const double snowRadian = (snowDegree * pi) / 180;
    const double snowsDistance = 21;
    const double snowsNumber = 5;

    Offset rainOffset = const Offset(-9, 52) +
        Offset.fromDirection(snowRadian, /*Height:*/ _snowAnimationValue);

    canvas.translate(offset.dx + rainOffset.dx, offset.dy + rainOffset.dy);

    Offset lineOffset = const Offset(-((snowsNumber * snowsDistance) / 2), 0);
    double snowsYChanges = -(flakesDistance / 2);

    for (int j = 0; j < snowsNumber; j++) {
      lineOffset = Offset(lineOffset.dx + snowsDistance, lineOffset.dy) +
          // Add rainYChanges :
          Offset.fromDirection(snowRadian, snowsYChanges);
      snowsYChanges = -snowsYChanges;
      for (int i = 0; i < flakesNumber; i++) {
        drawSnowFlake(
            canvas,
            Offset.fromDirection(snowRadian, (i * flakesDistance)) +
                lineOffset);
      }
    }

    canvas.restore();
  }

  void drawCloud(Canvas canvas,
      {Offset offset = const Offset(0, 0),
      double scale = 1.0,
      Color color = Colors.white}) {
    canvas.save();
    canvas.scale(0.05 + scale);

    canvas.translate(offset.dx - 39, offset.dy + 42);

    Paint paint = Paint()
      ..isAntiAlias = true
      ..color = color;

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    canvas.drawPath(path, paint);

    canvas.restore();
  }
}
