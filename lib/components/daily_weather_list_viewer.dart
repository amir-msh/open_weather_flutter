import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_weather_flutter/components/weather_indicator_painter/weather_indicator_painter.dart';
import 'package:open_weather_flutter/http_helpers/weather/weather.dart';
import 'package:open_weather_flutter/utils/weather_converters.dart';

class DailyWeatherListViewer extends StatelessWidget {
  final List<Daily> data;
  final bool isDay;
  final Axis scrollDirection;
  final ScrollController? scrollController;
  const DailyWeatherListViewer({
    super.key,
    required this.data,
    this.scrollDirection = Axis.horizontal,
    this.scrollController,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      controller: scrollController,
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(3, 0, 3, 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 50,
                  child: WeatherIndicatorPainter.fromIconCode(
                    scale: 0.3,
                    iconCode: data[index].weather.first.icon,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('EEE').format(
                    DateTime.fromMillisecondsSinceEpoch(
                      data[index].dt.floor() * 1000,
                      isUtc: true,
                    ),
                  ),
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: isDay
                        ? Colors.black.withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    // shadows: <Shadow>[
                    //   Shadow(
                    //     color: Colors.blue[200],
                    //     blurRadius: 5,
                    //   )
                    // ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${kelvinToCelsiusString(
                    data[index].temp.min,
                  )}'
                  ' / '
                  '${kelvinToCelsiusString(
                    data[index].temp.max,
                  )}°C',
                  style: TextStyle(
                    color: isDay ? Colors.black : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
