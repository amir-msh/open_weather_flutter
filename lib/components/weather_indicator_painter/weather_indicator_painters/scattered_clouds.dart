import 'package:flutter/material.dart';
import '../globals.dart';

class ScatteredClouds extends StatefulWidget {
  final bool day;
  final bool animation;
  const ScatteredClouds(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _ScatteredCloudsState();
}

class _ScatteredCloudsState extends State<ScatteredClouds>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _cloudAnimation;
  late final AnimationController _controller;
  static const double cloudAnimationRange = 7.5;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
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
        painter:
            _ScatteredCloudsCustomPainter(widget.day, _cloudAnimation.value),
        willChange: true,
        isComplex: true,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ScatteredCloudsCustomPainter extends CustomPainter {
  final bool day;
  final double cloudAnimationValue;
  _ScatteredCloudsCustomPainter(this.day, this.cloudAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(1.1);
    drawCloud(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawCloud(Canvas canvas) {
    canvas.translate(cloudAnimationValue - 39, 42);
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
