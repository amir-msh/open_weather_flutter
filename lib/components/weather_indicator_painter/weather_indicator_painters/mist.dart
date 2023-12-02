import 'package:flutter/material.dart';
import '../globals.dart';

class Mist extends StatefulWidget {
  final bool day;
  final bool animation;
  const Mist(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _MistState();
}

class _MistState extends State<Mist> with SingleTickerProviderStateMixin {
  late final Animation<double> _cloudAnimation;
  late final AnimationController _controller;
  static const double cloudAnimationRange = 5; // 7.5

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1750));
    _cloudAnimation = Tween<double>(
            begin: -cloudAnimationRange, end: cloudAnimationRange)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() => setState(() {}))
      ..addStatusListener(
        (AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _controller.forward();
          }
        },
      );
    if (widget.animation) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 0;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _MistCustomPainter(widget.day, _cloudAnimation.value),
        willChange: true,
        isComplex: true,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MistCustomPainter extends CustomPainter {
  final bool day;
  final double mistAnimationValue;
  _MistCustomPainter(this.day, this.mistAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2 + 5); // y-15
    drawSun(canvas);
    drawMist(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawSun(Canvas canvas) {
    canvas.drawCircle(
        const Offset(40, -14), 40, day ? Globals.sunPaint : Globals.moonPaint);
  }

  void drawMist(Canvas canvas, Size size) {
    canvas.translate(-39, 42);

    Paint paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      ..color = Globals.cloudPaint1.color;

    canvas.drawOval(
        Rect.fromLTWH(mistAnimationValue - 30, -77.5, 137, 80), paint);
    canvas.drawOval(
        Rect.fromLTWH(mistAnimationValue / 2 - 30, -100, 137, 100), paint);
  }
}
