import 'package:flutter/material.dart';
import '../globals.dart';

class FewClouds extends StatefulWidget {
  final bool day;
  final bool animation;
  const FewClouds(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _FewCloudsState();
}

class _FewCloudsState extends State<FewClouds>
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
        painter: _FewCloudsCustomPainter(widget.day, _cloudAnimation.value),
        willChange: true,
        isComplex: true,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _FewCloudsCustomPainter extends CustomPainter {
  final bool day;
  final double cloudAnimationValue;
  _FewCloudsCustomPainter(this.day, this.cloudAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    drawSun(canvas);
    fewClouds(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void fewClouds(Canvas canvas) {
    canvas.scale(1.15);

    drawSun(canvas);
    drawCloud(canvas);
  }

  void drawSun(Canvas canvas) {
    canvas.drawCircle(
        const Offset(40, -14), 40, day ? Globals.sunPaint : Globals.moonPaint);
  }

  void drawCloud(Canvas canvas) {
    canvas.translate(cloudAnimationValue - 39, 42);

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    canvas.drawPath(path, Globals.cloudPaint1);
  }
}
