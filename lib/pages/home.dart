import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:open_weather_flutter/components/hourly_weather_list_viewer.dart';
import 'package:open_weather_flutter/components/location_picker.dart';
import 'package:open_weather_flutter/components/non_scrollable_child_refresh_indicator.dart';
import 'package:open_weather_flutter/components/today_forecast_viewer.dart';
import 'package:open_weather_flutter/components/weather_indicator_painter/weather_indicator_painter.dart';
import 'package:open_weather_flutter/components/daily_weather_list_viewer.dart';
import 'package:open_weather_flutter/utils/constants.dart';
import 'package:open_weather_flutter/utils/weather_converters.dart';
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

  final _dailyForecastListScrollController = ScrollController();
  final _hourlyForecastListScrollController = ScrollController();

  @override
  void initState() {
    BlocProvider.of<WeatherCubit>(context).getCurrentLocationWeather();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  void dispose() {
    _dailyForecastListScrollController.dispose();
    _hourlyForecastListScrollController.dispose();
    super.dispose();
  }

  void blocListener(BuildContext context, WeatherStatus status) {
    Future.delayed(
      const Duration(milliseconds: 6),
      () {
        if (_hourlyForecastListScrollController.hasClients &&
            _dailyForecastListScrollController.hasClients) {
          _hourlyForecastListScrollController
            ..jumpTo(
              _hourlyForecastListScrollController.position.maxScrollExtent / 4,
            )
            ..animateTo(
              _hourlyForecastListScrollController.initialScrollOffset,
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeInOut,
            );
          _dailyForecastListScrollController
            ..jumpTo(
              _dailyForecastListScrollController.position.maxScrollExtent,
            )
            ..animateTo(
              _dailyForecastListScrollController.initialScrollOffset,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainMediaQuery = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<WeatherCubit, WeatherStatus>(
        listener: blocListener,
        listenWhen: (statusPrev, statusNow) {
          log(statusNow.runtimeType.toString());
          return statusNow is WeatherStatusOk;
        },
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: BlocBuilder<WeatherCubit, WeatherStatus>(
                builder: (context, data) {
                  final isDay = data is WeatherStatusOk
                      ? data.weatherData.current.isDay
                      : DateTime.now().hour > 6 && DateTime.now().hour < 18;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDay ? kDayGradient : kNightGradient,
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              bottom: true,
              maintainBottomViewPadding: true,
              child: Flex(
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
                            final weatherData = data.weatherData;
                            log(weatherData.timeZone);
                            return TodayForecastViewer(
                              weatherIndicator: SizedBox(
                                height: 275,
                                child: WeatherIndicatorPainter.fromIconCode(
                                  iconCode:
                                      data.weatherData.current.weather[0].icon,
                                  // code: WeatherCode.fewClouds,
                                  // isDay: false,
                                  scale: 1.3,
                                  animation: true,
                                ),
                              ),
                              locationTitle: humanizeDescription(
                                weatherData.timeZone,
                              ),
                              temperature: '${kelvinToCelsiusString(
                                weatherData.current.temp,
                              )}°',
                              description:
                                  weatherData.current.weather.first.description,
                              isCurrentLocation: data.isCurrentLocation,
                              isDay: weatherData.current.isDay,
                              onLocationButtonPressed: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  enableDrag: false,
                                  isDismissible: true,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return MediaQuery(
                                      data: mainMediaQuery,
                                      child: LocationPicker(
                                        isDay: weatherData.current.isDay,
                                      ),
                                    );
                                  },
                                ).whenComplete(
                                  () {
                                    log('Location picker closed!');
                                  },
                                );
                              },
                            );
                          } else if (data is WeatherStatusError) {
                            return Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.white54,
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 10,
                                      blurStyle: BlurStyle.outer,
                                      color: Colors.black38,
                                    )
                                  ],
                                ),
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error,
                                      size: 37,
                                      color: Colors.red[800]!,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      data.error.message,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      softWrap: true,
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed:
                                          BlocProvider.of<WeatherCubit>(context)
                                              .refreshWeatherData,
                                      child: const Text('Try again!'),
                                    ),
                                  ],
                                ),
                              ),
                            );
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
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    child: Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      direction: Axis.vertical,
                      children: [
                        SizedBox(
                          height: 130,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white10,
                            ),
                            child: BlocBuilder<WeatherCubit, WeatherStatus>(
                              builder: (context, data) {
                                if (data is WeatherStatusOk) {
                                  return DailyWeatherListViewer(
                                    data: data.weatherData.daily,
                                    scrollController:
                                        _dailyForecastListScrollController,
                                    isDay: data.weatherData.current.isDay,
                                  );
                                } else if (data is WeatherStatusError) {
                                  return const SizedBox();
                                }
                                return const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                );
                              },
                            ),
                          ),
                        ),
                        // BlocBuilder<WeatherCubit, WeatherStatus>(
                        //   builder: (context, data) {
                        //     final isDay = data is WeatherStatusOk
                        //         ? data.weatherData.current.isDay
                        //         : DateTime.now().hour > 6 &&
                        //             DateTime.now().hour < 18;
                        //     return Divider(
                        //       thickness: 2.0,
                        //       color: isDay
                        //           ? Colors.white.withOpacity(.30)
                        //           : Colors.black.withOpacity(.01),
                        //       height: 2.0,
                        //       indent: 0,
                        //       endIndent: 0,
                        //     );
                        //   },
                        // ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 90,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints:
                                const BoxConstraints.expand(width: 1000),
                            child: BlocBuilder<WeatherCubit, WeatherStatus>(
                              builder: (context, data) {
                                if (data is WeatherStatusOk) {
                                  return HourlyWeatherListViewer(
                                    data: data.weatherData.hourly,
                                    scrollController:
                                        _hourlyForecastListScrollController,
                                    isDay: data.weatherData.current.isDay,
                                  );
                                } else if (data is WeatherStatusError) {
                                  return const SizedBox();
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
            ),
          ],
        ),
      ),
    );
  }
}
