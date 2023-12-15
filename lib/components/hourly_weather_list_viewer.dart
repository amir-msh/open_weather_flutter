import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_weather_flutter/components/weather_indicator_painter/weather_indicator_painter.dart';
import 'package:open_weather_flutter/http_helpers/weather/weather.dart';
import 'package:open_weather_flutter/utils/weather_converters.dart';

class HourlyWeatherListViewer extends StatelessWidget {
  final List<Hourly> data;
  final bool isDay;
  final Axis scrollDirection;
  final ScrollController? scrollController;

  const HourlyWeatherListViewer({
    super.key,
    required this.data,
    this.scrollDirection = Axis.horizontal,
    this.scrollController,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      controller: scrollController,
      scrollDirection: scrollDirection,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      itemCount: data.length,
      separatorBuilder: (context, index) {
        return const VerticalDivider(
          indent: 10,
          endIndent: 10,
          width: 1,
          thickness: 0.75,
          color: Colors.white24,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: WeatherIndicatorPainter.fromIconCode(
                  scale: 0.21,
                  iconCode: data[index].weather.first.icon,
                ),
              ),
              Text(
                DateFormat('HH').format(dtToDateTime(data[index].dt)),
                style: TextStyle(
                  color: isDay
                      ? Colors.black.withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${kelvinToCelsiusString(
                  data[index].temp,
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
