import 'dart:math';
import 'dart:ui';

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
  late final Animation<double> _animation;
  AnimationController? _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1750,
      ),
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );

    if (widget.animation) {
      _controller!.repeat(reverse: true);
    } else {
      _controller!.value = 0.5;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ClearSkyCustomPainter(
            animationValue: _animation.value,
            day: widget.day,
          ),
          willChange: true,
          isComplex: true,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class _ClearSkyCustomPainter extends CustomPainter {
  final double animationValue;
  final bool day;

  _ClearSkyCustomPainter({
    required this.animationValue,
    required this.day,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    if (day) {
      drawSun(canvas);
    } else {
      drawMoon(canvas, size);
    }
  }

  void drawSun(Canvas canvas) {
    canvas.drawCircle(
      Offset.zero,
      50,
      Globals.sunPaint,
    );

    canvas.clipPath(
      Path()
        ..addOval(
          Rect.fromCircle(center: Offset.zero, radius: 49.9),
        ),
    );

    final double glowBlur = Tween<double>(
      begin: 20,
      end: 39,
    ).transform(animationValue);

    canvas.drawCircle(
      Offset.fromDirection(
        Tween<double>(
          begin: 0,
          end: pi * 2,
        ).transform(animationValue),
        Tween<double>(begin: 10, end: 45).transform(animationValue),
      ),
      Tween<double>(begin: 50, end: 80).transform(animationValue),
      Paint()
        ..color = Colors.amber.withOpacity(
          Tween<double>(
            begin: 0.75,
            end: 0.5,
          ).transform(animationValue),
        )
        ..filterQuality = FilterQuality.low
        ..imageFilter = ImageFilter.blur(
          sigmaX: glowBlur,
          sigmaY: glowBlur,
          tileMode: TileMode.repeated,
        ),
    );
  }

  void drawMoon(Canvas canvas, Size size) {
    final double slope = -1.37 +
        Tween<double>(
          begin: -0.1,
          end: 0.1,
        ).transform(
          animationValue,
        );

    const double magnitude = 0.8;
    const double radius = 57;
    const double innerRadius = 55;

    final startOffset = Offset.fromDirection(
      slope - pi + magnitude,
      radius,
    );

    final path = Path()
      ..moveTo(startOffset.dx, startOffset.dy)
      ..arcToPoint(
        Offset.fromDirection(slope, radius),
        radius: const Radius.circular(radius),
        clockwise: false,
        largeArc: true,
      )
      ..arcToPoint(
        startOffset,
        radius: const Radius.circular(innerRadius),
        clockwise: true,
      );

    final blur = Tween<double>(
      begin: 2.5,
      end: 5,
    ).transform(animationValue);

    canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = Globals.moonPaint.isAntiAlias
        ..color = Colors.grey[300]!
        ..imageFilter = ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
          tileMode: TileMode.decal,
        ),
    );

    canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = Globals.moonPaint.isAntiAlias
        ..color = Globals.moonPaint.color
        ..shader = RadialGradient(
          colors: const [
            Colors.white,
            Color(0xFFe5e5e5),
            Colors.white,
          ],
          // const [
          //   Color(0xFFe5e5e5),
          //   Color.fromARGB(255, 196, 188, 190),
          //   Color(0xFFe5e5e5),
          // ],
          radius: 0.78,
          tileMode: TileMode.clamp,
          center: Alignment(
            Tween<double>(
              begin: -1.05,
              end: -1.1,
            ).transform(animationValue),
            Tween<double>(
              begin: -1,
              end: -1.2,
            ).transform(animationValue),
          ),
          stops: const [
            0.2,
            0.5,
            0.95,
          ],
        ).createShader(
          const Rect.fromLTWH(-18, -9, 160, 160),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _ClearSkyCustomPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.day != day;
  }
}
