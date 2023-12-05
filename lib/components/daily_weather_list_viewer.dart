import 'package:flutter/material.dart';
import 'package:open_weather_flutter/components/weather_indicator_painter/weather_indicator_painter.dart';
import 'package:open_weather_flutter/http_helpers/weather/weather.dart';
import 'package:open_weather_flutter/utils/weather_converters.dart';

class DailyWeatherListViewer extends StatelessWidget {
  final List<Daily> data;
  final bool isDay;
  final Axis scrollDirection;
  const DailyWeatherListViewer(
    this.data, {
    super.key,
    this.scrollDirection = Axis.horizontal,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: scrollDirection,
      padding: const EdgeInsets.symmetric(horizontal: 1),
      itemCount: data.length,
      separatorBuilder: (context, index) {
        return const VerticalDivider(
          indent: 10,
          endIndent: 10,
          width: 5,
          thickness: 0.75,
          color: Colors.white30,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: WeatherIndicatorPainter.fromIconCode(
                  scale: 0.28,
                  iconCode: data[index].weather.first.icon,
                ),
              ),
              Text(
                '${kelvinToCelsiusString(
                  data[index].temp.min,
                )}'
                '-'
                '${kelvinToCelsiusString(
                  data[index].temp.max,
                )}°C',
                style: TextStyle(
                  color: isDay ? Colors.black : Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
