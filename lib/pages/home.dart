import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_weather_flutter/components/hourly_weather_list_viewer.dart';
import 'package:open_weather_flutter/components/non_scrollable_child_refresh_indicator.dart';
import 'package:open_weather_flutter/components/weather_indicator_painter/weather_indicator_painter.dart';
import 'package:open_weather_flutter/components/daily_weather_list_viewer.dart';
import 'package:open_weather_flutter/utils/constants.dart';
import 'package:open_weather_flutter/weather/weather_bloc.dart';
import 'package:open_weather_flutter/weather/weather_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    BlocProvider.of<WeatherCubit>(context).getCurrentLocationWeather();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          BlocBuilder<WeatherCubit, WeatherStatus>(
            builder: (context, data) {
              final isDay = data is WeatherStatusOk
                  ? data.weatherData.current.isDay
                  : DateTime.now().hour > 6 && DateTime.now().hour < 18;
              return Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDay ? kDayGradient : kNightGradient,
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              );
            },
          ),
          Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            clipBehavior: Clip.none,
            children: [
              Expanded(
                child: NonScrollableChildRefreshIndicator(
                  refreshIndicatorKey: _refreshIndicatorKey,
                  onRefresh: () async {
                    log('onRefresh()');
                    await BlocProvider.of<WeatherCubit>(
                      context,
                    ).refreshWeatherData();
                  },
                  child: BlocBuilder<WeatherCubit, WeatherStatus>(
                    builder: (context, data) {
                      if (data is WeatherStatusOk) {
                        return WeatherIndicatorPainter.fromIconCode(
                          scale: 1.5,
                          // iconCode: data.weatherData.current.weather[0].icon,
                          iconCode: '1d',
                          animation: true,
                        );
                      } else if (data is WeatherStatusError) {
                        return const Icon(Icons.error);
                      } else {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                    },
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 200,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          color: Colors.white24,
                        ),
                        child: BlocBuilder<WeatherCubit, WeatherStatus>(
                          builder: (context, data) {
                            if (data is WeatherStatusOk) {
                              return DailyWeatherListViewer(
                                data.weatherData.daily,
                                isDay: data.weatherData.current.isDay,
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          },
                        ),
                      ),
                    ),
                    BlocBuilder<WeatherCubit, WeatherStatus>(
                      builder: (context, data) {
                        final isDay = data is WeatherStatusOk
                            ? data.weatherData.current.isDay
                            : DateTime.now().hour > 6 &&
                                DateTime.now().hour < 18;
                        return Divider(
                          thickness: 2.0,
                          color: isDay
                              ? Colors.white.withAlpha(75)
                              : Colors.black.withAlpha(75),
                          height: 1,
                          indent: 0,
                          endIndent: 0,
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white24,
                        child: BlocBuilder<WeatherCubit, WeatherStatus>(
                          builder: (context, data) {
                            if (data is WeatherStatusOk) {
                              return HourlyWeatherListViewer(
                                data.weatherData.hourly,
                                isDay: data.weatherData.current.isDay,
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
