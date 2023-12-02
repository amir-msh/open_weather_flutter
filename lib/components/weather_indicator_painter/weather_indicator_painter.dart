import 'package:flutter/material.dart';
import 'weather_indicator_painters/clear_sky.dart';
import 'weather_indicator_painters/few_clouds.dart';
import 'weather_indicator_painters/scattered_clouds.dart';
import 'weather_indicator_painters/broken_clouds.dart';
import 'weather_indicator_painters/rain.dart';
import 'weather_indicator_painters/shower_rain.dart';
import 'weather_indicator_painters/snow.dart';
import 'weather_indicator_painters/mist.dart';
import 'weather_indicator_painters/thunderstorm.dart';

class WeatherIndicatorPainter extends StatelessWidget {
  final double scale;
  final bool animation;
  final int code;
  final bool day;

  const WeatherIndicatorPainter({
    super.key,
    required this.code,
    this.day = true,
    this.scale = 1.0,
    this.animation = false,
  });

  Widget painterSwitcher() {
    switch (code) {
      case 1:
        return ClearSky(day, animation); // ClearSky
      case 2:
        return FewClouds(day, animation); // FewClouds
      case 3:
        return ScatteredClouds(day, animation); // ScatteredClouds
      case 4:
        return BrokenClouds(day, animation); // BrokenClouds (3 Clouds)
      case 9:
        return ShowerRain(day, animation); // ShowerRain
      case 10:
        return Rain(day, animation); // Rain
      case 11:
        return Thunderstorm(day, animation); // Thunderstorm
      case 13:
        return Snow(day, animation); // Snow
      case 50:
        return Mist(day, animation); // Mist
      default:
        return FewClouds(day, animation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.85, 0.95, 1], // 0.85, 0.95, 1
                colors: <Color>[
                  Colors.black.withAlpha(255),
                  Colors.black.withAlpha(0),
                  Colors.black.withAlpha(0),
                ],
              ).createShader(bounds);
            },
            child: Transform.scale(
              scale: scale,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 750),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: painterSwitcher(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
