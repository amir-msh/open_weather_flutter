import 'package:flutter/material.dart';
import '../globals.dart';

class Thunderstorm extends StatefulWidget {
  final bool day;
  final bool animation;
  const Thunderstorm(this.day, this.animation, {super.key});
  @override
  State<StatefulWidget> createState() => _ThunderstormState();
}

class _ThunderstormState extends State<Thunderstorm>
    with TickerProviderStateMixin {
  late final Animation<double> _cloudAnimation;
  late final AnimationController _cloudAnimationController;
  static const double cloudAnimationRange = 3;

  late final Animation<int> _lightningAnimation;
  late final AnimationController _lightningAnimationController;

  @override
  void initState() {
    _cloudAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1250));
    _cloudAnimation = Tween<double>(
            begin: -cloudAnimationRange, end: cloudAnimationRange)
        .animate(CurvedAnimation(
            parent: _cloudAnimationController, curve: Curves.easeInOut))
      ..addListener(() => setState(() {}))
      ..addStatusListener(
        (AnimationStatus status) {
          if (status == AnimationStatus.completed && widget.animation) {
            _cloudAnimationController.reverse();
          } else if (status == AnimationStatus.dismissed && widget.animation) {
            _cloudAnimationController.forward();
          }
        },
      );

    _lightningAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    ); // 250

    _lightningAnimation = IntTween(
      begin: 0,
      end: 255,
    ).animate(CurvedAnimation(
        parent: _lightningAnimationController, curve: Curves.bounceOut))
      ..addListener(() => setState(() {}))
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed && widget.animation) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _lightningAnimationController.reverse();
              //_lightningAnimationController.reset();
              //Future.delayed(const Duration(milliseconds: 500), () => _lightningAnimationController.forward(from: 0));
            });
          } else if (status == AnimationStatus.dismissed && widget.animation) {
            _lightningAnimationController.forward();
          }
        },
      );

    if (widget.animation) {
      _cloudAnimationController.forward(from: 0);
      _lightningAnimationController.forward();
    } else {
      _lightningAnimationController.value = 255;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ThunderstormCustomPainter(
        widget.day,
        _cloudAnimation.value,
        _lightningAnimation.value,
      ), // TODO : Improve perfoemance
      willChange: true,
      isComplex: true,
    );
  }

  @override
  void dispose() {
    _cloudAnimationController.stop();
    _lightningAnimationController.stop();
    _cloudAnimationController.dispose();
    _lightningAnimationController.dispose();
    super.dispose();
  }
}

class _ThunderstormCustomPainter extends CustomPainter {
  final double cloudAnimationValue;
  final int lightningAnimationValue;
  double tempAnimationValue = 0;
  final bool day;
  _ThunderstormCustomPainter(
      this.day, this.cloudAnimationValue, this.lightningAnimationValue);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2 - 5, size.height / 2 + 5);
    canvas.scale(0.9);
    thunderstorm(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void thunderstorm(Canvas canvas, Size size) {
    canvas.scale(1.1); // 1.1, 0.95
    canvas.translate(0, -30);
    tempAnimationValue = cloudAnimationValue / 1.25;

    drawBackgroundCloud(canvas);
    drawMiddleCloud(canvas);
    drawForegroundCloud(canvas);
  }

  void drawBackgroundCloud(Canvas canvas) {
    canvas.save();
    canvas.scale(0.95); // 0.9

    canvas.translate(-5 - tempAnimationValue, 32);
    //canvas.translate(-9 - cloudAnimationValue / 1.5, 32);

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    drawLightning(canvas, offset: const Offset(40, 0), scale: 0.65);

    canvas.drawPath(path, Globals.cloudPaint2);
    canvas.restore();
  }

  void drawMiddleCloud(Canvas canvas) {
    canvas.save();
    canvas.scale(0.77);

    canvas.translate(cloudAnimationValue / 1.75 - 90, 32);
    //canvas.translate(-9 - cloudAnimationValue / 1.5, 32);

    Path path = Path();
    path.arcToPoint(const Offset(0, -48), radius: const Radius.circular(10));
    path.arcToPoint(const Offset(60, -57), radius: const Radius.circular(30));
    path.arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5));
    path.arcToPoint(const Offset(90, 0), radius: const Radius.circular(5));
    path.close();

    drawLightning(canvas, offset: const Offset(-40, 0), scale: 0.60);

    canvas.drawPath(path, Globals.cloudPaint3);

    canvas.restore();
  }

  void drawForegroundCloud(Canvas canvas) {
    canvas.translate(cloudAnimationValue - 39, 52);
    //canvas.translate(-39, 42);

    Path path = Path()
      ..arcToPoint(const Offset(0, -48), radius: const Radius.circular(10))
      ..arcToPoint(const Offset(60, -57), radius: const Radius.circular(30))
      ..arcToPoint(const Offset(85, -34), radius: const Radius.circular(17.5))
      ..arcToPoint(const Offset(90, 0), radius: const Radius.circular(5))
      ..close();

    drawLightning(canvas, offset: const Offset(30, 0), scale: 0.70);
    drawLightning(canvas, scale: 0.8);
    drawLightning(canvas, offset: const Offset(-30, 0), scale: 0.70);

    canvas.drawPath(path, Globals.cloudPaint1);
  }

  void drawLightning(Canvas canvas,
      {Offset offset = const Offset(0, 0), double scale = 1.0}) {
    canvas.save();
    canvas.translate(offset.dx + 47, offset.dy - 12);
    canvas.scale(scale);

    Path path = Path()
      ..moveTo(0, 7.5)
      ..lineTo(10, 7.5)
      ..lineTo(-6.5, 30)
      ..lineTo(3, 30) // x=5
      ..lineTo(-10, 50)
      ..lineTo(-1, 50) // x = 0
      ..lineTo(-23, 83) // bottom
      ..lineTo(-10, 56)
      ..lineTo(-20, 56)
      ..lineTo(-7, 35)
      ..lineTo(-17, 35)
      //..lineTo(-50, 75)
      ..close();

    Paint paint = Paint()
      ..color = Colors.blue.withAlpha(lightningAnimationValue)
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    canvas.restore();
  }
}
