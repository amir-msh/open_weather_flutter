import 'package:flutter/material.dart';
import 'package:open_weather_flutter/components/weather_indicator_painter/globals.dart';
import 'weather_indicator_painters/clear_sky.dart';
import 'weather_indicator_painters/few_clouds.dart';
import 'weather_indicator_painters/scattered_clouds.dart';
import 'weather_indicator_painters/broken_clouds.dart';
import 'weather_indicator_painters/rain.dart';
import 'weather_indicator_painters/shower_rain.dart';
import 'weather_indicator_painters/snow.dart';
import 'weather_indicator_painters/mist.dart';
import 'weather_indicator_painters/thunderstorm.dart';

enum WeatherCode {
  clearSky,
  fewClouds,
  scatteredClouds,
  brokenClouds,
  showerRain,
  rain,
  thunderstorm,
  snow,
  mist,
}

const mapWeatherCodeToEnum = <int, WeatherCode>{
  1: WeatherCode.clearSky,
  2: WeatherCode.fewClouds,
  3: WeatherCode.scatteredClouds,
  4: WeatherCode.brokenClouds,
  9: WeatherCode.showerRain,
  10: WeatherCode.rain,
  11: WeatherCode.thunderstorm,
  13: WeatherCode.snow,
  50: WeatherCode.mist,
};

class WeatherIndicatorPainter extends StatelessWidget {
  final double scale;
  final bool animation;
  final WeatherCode? code;
  final bool isDay;

  const WeatherIndicatorPainter({
    super.key,
    this.code,
    this.isDay = true,
    this.scale = 1.0,
    this.animation = Globals.animationEnabledDefault,
  });

  factory WeatherIndicatorPainter.fromIconCode({
    Key? key,
    required String iconCode,
    double scale = 1.0,
    bool animation = Globals.animationEnabledDefault,
  }) {
    final weatherCode = int.tryParse(
      iconCode.substring(0, iconCode.length - 1),
    );

    final code = weatherCode == null ? null : mapWeatherCodeToEnum[weatherCode];

    return WeatherIndicatorPainter(
      key: key,
      code: code,
      isDay: iconCode.characters.last != 'n',
      scale: scale,
      animation: animation,
    );
  }

  Widget painterSwitcher() {
    switch (code) {
      case WeatherCode.clearSky:
        return ClearSky(isDay, animation);
      case WeatherCode.fewClouds:
        return FewClouds(isDay, animation);
      case WeatherCode.scatteredClouds:
        return ScatteredClouds(isDay, animation);
      case WeatherCode.brokenClouds:
        return BrokenClouds(isDay, animation);
      case WeatherCode.showerRain:
        return ShowerRain(isDay, animation);
      case WeatherCode.rain:
        return Rain(isDay, animation);
      case WeatherCode.thunderstorm:
        return Thunderstorm(isDay, animation);
      case WeatherCode.snow:
        return Snow(isDay, animation);
      case WeatherCode.mist:
        return Mist(isDay, animation);
      default:
        return FewClouds(isDay, animation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
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
                stops: const [0.825, 0.95, 1], // 0.85, 0.95, 1
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
