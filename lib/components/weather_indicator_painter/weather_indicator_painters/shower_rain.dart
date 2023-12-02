import 'dart:math';
import 'package:flutter/material.dart';
import '../globals.dart';

class ShowerRain extends StatefulWidget {
  final bool day;
  final bool animation;
  const ShowerRain(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _ShowerRainState();
}

class _ShowerRainState extends State<ShowerRain>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _showerRainAnimation;
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _showerRainAnimation = Tween<double>(
            begin: -Globals.dropsDistance + Globals.startRainFrom,
            end: 0 + Globals.startRainFrom)
        .animate(_controller)
      //..drive(CurveTween(curve: Curves.easeInCirc))
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
        painter:
            _ShowerRainCustomPainter(widget.day, _showerRainAnimation.value),
        willChange: true,
        isComplex: true,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ShowerRainCustomPainter extends CustomPainter {
  final double _showerRainAnimationValue;
  final bool day;
  _ShowerRainCustomPainter(this.day, this._showerRainAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2 + 5);
    showerRain(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void showerRain(Canvas canvas) {
    canvas.translate(-12, -30); // x=0
    drawShowerRain(canvas);

    canvas.scale(1.1);
    drawCloud(canvas,
        offset: const Offset(30, -20),
        scale: 0.9,
        color: const Color.fromARGB(255, 100, 100, 100));

    drawCloud(canvas);
  }

  void drawShowerRain(Canvas canvas, [Offset offset = const Offset(0, 0)]) {
    canvas.save();

    const double dropsHeight = 6; // 6
    const int dropsNumber = 6; // 6
    const double showerRainDegree = 100; // 100
    const double showerRainRadian = (showerRainDegree * pi) / 180;
    const double showerRainsDistance = 10; // 10
    const double showerRainsNumber = 10; // 10

    Offset showerRainOffset = const Offset(-5, 52) +
        Offset.fromDirection(
            showerRainRadian, /*Height:*/ _showerRainAnimationValue);

    canvas.translate(
        offset.dx + showerRainOffset.dx, offset.dy + showerRainOffset.dy);

    Paint paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    Offset lineOffset =
        const Offset(-((showerRainsNumber * showerRainsDistance) / 2), 0);
    double showerRainYChanges = -5;

    for (int j = 0; j < showerRainsNumber; j++) {
      lineOffset = Offset(lineOffset.dx + showerRainsDistance, lineOffset.dy) +
          // Add showerRainYChanges :
          Offset.fromDirection(showerRainRadian, showerRainYChanges);
      showerRainYChanges = -showerRainYChanges;
      for (int i = 0; i < dropsNumber; i++) {
        canvas.drawLine(
            Offset.fromDirection(
                    showerRainRadian, (i * Globals.dropsDistance)) +
                lineOffset,
            Offset.fromDirection(showerRainRadian,
                    (i * Globals.dropsDistance) + dropsHeight) +
                lineOffset,
            paint);
      }
    }

    canvas.restore();
  }

  void drawCloud(Canvas canvas,
      {Offset offset = const Offset(0, 0),
      double scale = 1.0,
      Color color = Colors.white}) {
    canvas.save();

    if (scale != 1.0) canvas.scale(scale);

    canvas.translate(offset.dx - 39, offset.dy + 42);
    //canvas.translate(-39, 42);

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
