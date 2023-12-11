import 'dart:math';
import 'dart:ui';

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
  late final CurvedAnimation curvedAnimation;
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.animation) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FewCloudsCustomPainter(
            widget.day,
            curvedAnimation.value,
          ),
          willChange: true,
          isComplex: true,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    curvedAnimation.dispose();
    super.dispose();
  }
}

class _FewCloudsCustomPainter extends CustomPainter {
  final bool day;
  final double animation;
  _FewCloudsCustomPainter(this.day, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    fewClouds(canvas);
  }

  void fewClouds(Canvas canvas) {
    canvas.scale(1.15);

    canvas.save();
    drawSun(canvas);
    canvas.restore();

    drawCloud(canvas);
  }

  void drawSun(Canvas canvas) {
    canvas.translate(40, -14);

    if (!day) {
      canvas.drawCircle(
        Offset.zero,
        40,
        Paint()
          ..color = Color(0xFF99988a)
          ..isAntiAlias = Globals.moonPaint.isAntiAlias,
      );
      return;
    }

    canvas.drawCircle(
      Offset.zero,
      40,
      Globals.sunPaint,
    );

    canvas.clipPath(
      Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset.zero,
            radius: 39.9,
          ),
        ),
    );

    final double glowBlur = Tween<double>(
      begin: 20,
      end: 39,
    ).transform(animation);

    canvas.drawCircle(
      Offset.fromDirection(
        Tween<double>(
          begin: 0,
          end: pi * 2,
        ).transform(animation),
        Tween<double>(begin: 10, end: 45).transform(animation),
      ),
      Tween<double>(begin: 50, end: 80).transform(animation),
      Paint()
        ..color = Colors.amber.withOpacity(
          Tween<double>(
            begin: 0.75,
            end: 0.5,
          ).transform(animation),
        )
        ..filterQuality = FilterQuality.low
        ..imageFilter = ImageFilter.blur(
          sigmaX: glowBlur,
          sigmaY: glowBlur,
          tileMode: TileMode.repeated,
        ),
    );
  }

  void drawCloud(Canvas canvas) {
    final change = Tween<double>(
      begin: -7.5,
      end: 7.5,
    ).transform(animation);

    canvas.translate(change - 39, 42);

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    canvas.drawPath(path, Globals.cloudPaint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
