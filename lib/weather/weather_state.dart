import 'package:open_weather_flutter/http_helpers/weather/weather.dart';

enum WeatherStatusErrors {
  noInternet('No internet connection!'),
  noLocation('Location is not available!'),
  noAccess('Location permission is denied!'),
  unknown('An unknown error was happened!');

  const WeatherStatusErrors(this.message);

  final String message;
}

sealed class WeatherStatus {
  WeatherStatus();
}

class WeatherStatusInitial extends WeatherStatus {
  WeatherStatusInitial() : super();
}

class WeatherStatusLoading extends WeatherStatus {
  WeatherStatusLoading() : super();
}

class WeatherStatusOk extends WeatherStatus {
  final Weather weatherData;
  final bool isCurrentLocation;

  WeatherStatusOk({
    required this.weatherData,
    required this.isCurrentLocation,
  });

  // @override
  // int get hashCode => Object.hashAll(objects);
}

class WeatherStatusError extends WeatherStatus {
  final WeatherStatusErrors error;

  WeatherStatusError([
    this.error = WeatherStatusErrors.unknown,
  ]) : super();
}
