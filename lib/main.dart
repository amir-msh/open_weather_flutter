import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_weather_flutter/components/custom_scroll_behavior.dart';
import 'package:open_weather_flutter/http_helpers/weather/weather_http_helper_mock.dart';
import 'package:open_weather_flutter/pages/home.dart';
import 'package:open_weather_flutter/utils/credentials.dart';
import 'package:open_weather_flutter/weather/weather_bloc.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherCubit(
        const WeatherHttpHeplerMock(owmApiToken),
      ),
      lazy: false,
      child: MaterialApp(
        title: 'Open Weather FLutter',
        scrollBehavior: CustomScrollBehavior(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
