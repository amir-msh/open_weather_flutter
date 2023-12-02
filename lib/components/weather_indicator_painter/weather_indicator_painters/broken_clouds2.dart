import 'package:flutter/material.dart';
import '../globals.dart';

class BrokenClouds2 extends StatefulWidget {
  final bool day;
  final bool animation;
  const BrokenClouds2(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _BrokenClouds2State();
}

class _BrokenClouds2State extends State<BrokenClouds2>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _cloudAnimation;
  late final AnimationController _controller;
  static const double cloudAnimationRange = 5;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1250));
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
        painter: _BrokenClouds2CustomPainter(widget.day, _cloudAnimation.value),
        willChange: true,
        isComplex: true,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _BrokenClouds2CustomPainter extends CustomPainter {
  final double cloudAnimationValue;
  double tempAnimationValue = 0;
  final bool day;
  _BrokenClouds2CustomPainter(this.day, this.cloudAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    brokenClouds(canvas);
    //cloudAnimationValue
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void brokenClouds(Canvas canvas) {
    canvas.scale(1.1);
    canvas.translate(-9, 0);
    tempAnimationValue = cloudAnimationValue / 1.25;
    drawBackgroundCloud(canvas);
    drawForegroundCloud(canvas);
  }

  void drawBackgroundCloud(Canvas canvas) {
    canvas.scale(0.9);

    canvas.translate(-5 - tempAnimationValue, 32);
    //canvas.translate(-9 - cloudAnimationValue / 1.5, 32);

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    canvas.drawPath(path, Globals.cloudPaint2);

    canvas.translate(5 + tempAnimationValue, -32);
    //canvas.translate(9 + cloudAnimationValue / 1.5, -32);

    canvas.scale(1.111111111111111); // 1/0.9 = 1.111111111111111 => Reset Scale
  }

  void drawForegroundCloud(Canvas canvas) {
    canvas.translate(cloudAnimationValue - 39, 52);
    //canvas.translate(-39, 42);

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    canvas.drawPath(path, Globals.cloudPaint1);
  }
}
