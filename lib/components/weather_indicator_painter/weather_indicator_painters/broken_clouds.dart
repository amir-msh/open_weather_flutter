import 'package:flutter/material.dart';
import '../globals.dart';

class BrokenClouds extends StatefulWidget {
  final bool day;
  final bool animation;
  const BrokenClouds(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _BrokenCloudsState();
}

class _BrokenCloudsState extends State<BrokenClouds>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _cloudAnimation;
  late final AnimationController _controller;
  static const double cloudAnimationRange = 3;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
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
        painter: _BrokenCloudsCustomPainter(widget.day, _cloudAnimation.value),
        willChange: true,
        isComplex: true,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _BrokenCloudsCustomPainter extends CustomPainter {
  final double cloudAnimationValue;
  double tempAnimationValue = 0;
  final bool day;
  _BrokenCloudsCustomPainter(this.day, this.cloudAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2 - 5, size.height / 2);
    brokenClouds(canvas);
    //cloudAnimationValue
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void brokenClouds(Canvas canvas) {
    // canvas.scale(1.0); // 1.1, 0.95
    // canvas.translate(0, 0);
    tempAnimationValue = cloudAnimationValue / 1.25;
    drawBackgroundCloud(canvas);
    drawMiddleCloud(canvas);
    drawForegroundCloud(canvas);
  }

  void drawBackgroundCloud(Canvas canvas) {
    canvas.save();
    canvas.scale(0.95);
    canvas.translate(-5 - tempAnimationValue, 32);
    //canvas.translate(-9 - cloudAnimationValue / 1.5, 32);

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    canvas.drawPath(path, Globals.cloudPaint2);

    canvas.restore();
  }

  void drawMiddleCloud(Canvas canvas) {
    canvas.save();

    canvas.scale(0.75);

    canvas.translate(cloudAnimationValue / 1.5 - 90, 32);

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    canvas.drawPath(path, Globals.cloudPaint3);

    canvas.restore();
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
