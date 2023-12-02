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
  //Animation<double> _cloudAnimation;
  //AnimationController _controller;
  //static const double cloudAnimationRange = 3;

  @override
  void initState() {
    /*
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _cloudAnimation = Tween<double>(begin: 0.5, end: cloudAnimationRange)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
          ..addListener(() => setState(() {}))
          ..addStatusListener(
            (AnimationStatus status) {
              if (status == AnimationStatus.completed)
                _controller.reverse();
              else if (status == AnimationStatus.dismissed)
                _controller.forward();
            },
          );
    _controller.forward(from: 0);
    */
    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ClearSkyCustomPainter(widget.day), //_cloudAnimation.value
        willChange: true,
        isComplex: true,
      );

  @override
  void dispose() {
    //_controller.dispose();
    super.dispose();
  }
}

class _ClearSkyCustomPainter extends CustomPainter {
  final bool day;
  //final double sunAnimation;
  _ClearSkyCustomPainter(this.day); //this.sunAnimation

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    drawSun(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  void drawSun(Canvas canvas) {
    canvas.drawCircle(
      const Offset(0, 0),
      50,
      day ? Globals.sunPaint : Globals.moonPaint,
    );
  }
}
