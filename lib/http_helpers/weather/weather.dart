import 'package:flutter/material.dart';

class Weather {
  final num lat;
  final num lon;
  final String timeZone;
  final Current current;
  final List minutely; // List<Minutely>
  final List<Hourly> hourly;
  final List<Daily> daily;

  Weather({
    required this.lat,
    required this.lon,
    required this.timeZone,
    required this.current,
    required this.minutely,
    required this.hourly,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      lat: json['lat'],
      lon: json['lon'],
      timeZone: json['timezone'],
      current: Current.fromJson(json['current']),
      minutely: [], // json['minutely'],
      hourly: List.generate(
        json['hourly']?.length ?? 0, // TODO : Optimize
        (index) => Hourly.fromJson(json['hourly'][index]),
      ),
      daily: List.generate(
        json['daily']?.length ?? 0, // TODO : Optimize
        (index) => Daily.fromJson(json['daily'][index]),
      ),
    );
  }
}

class WeatherData {
  final num id;
  final String main;
  final String description;
  final String icon;

  WeatherData({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  bool get isDay => icon.characters.last == 'd';

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class DailyTempData {
  final num day;
  final num min;
  final num max;
  final num night;
  final num eve;
  final num morn;

  DailyTempData({
    required this.day,
    required this.min,
    required this.max,
    required this.night,
    required this.eve,
    required this.morn,
  });

  factory DailyTempData.fromJson(Map<String, dynamic> json) {
    return DailyTempData(
      day: json['day'],
      min: json['min'],
      max: json['max'],
      night: json['night'],
      eve: json['eve'],
      morn: json['morn'],
    );
  }
}

class DailyFeelsLikeData {
  final num day;
  final num night;
  final num eve;
  final num morn;

  DailyFeelsLikeData({
    required this.day,
    required this.night,
    required this.eve,
    required this.morn,
  });

  factory DailyFeelsLikeData.fromJson(Map<String, dynamic> json) {
    return DailyFeelsLikeData(
      day: json['day'],
      night: json['night'],
      eve: json['eve'],
      morn: json['morn'],
    );
  }
}

class Current {
  final int dt;
  final num temp;
  final num feelsLike;
  final num pressure;
  final num humidity;
  final num uvi;
  final num clouds;
  final num visibility;
  final num windSpeed;
  final num windDeg;
  final List<WeatherData> weather;
  // Custom:
  final bool isDay;

  Current({
    required this.dt,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.uvi,
    required this.clouds,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    required this.weather,
    // Custom:
    required this.isDay,
  });

  factory Current.fromJson(Map<String, dynamic> json) {
    return Current(
      dt: json['dt'],
      temp: json['temp'],
      feelsLike: json['feels_like'],
      pressure: json['pressure'],
      humidity: json['humidity'],
      uvi: json['uvi'],
      clouds: json['clouds'],
      visibility: json['visibility'],
      windSpeed: json['wind_speed'],
      windDeg: json['wind_deg'],
      weather: List.generate(
        json['weather']?.length ?? 0, // TODO : Optimize
        (index) => WeatherData.fromJson(json['weather'][index]),
      ),
      isDay: json['weather'][0]['icon']
              [json['weather'][0]['icon'].length - 1] ==
          'd',
    );
  }
}

class Minutely {
  final int dt;
  final num precipitation;

  Minutely({
    required this.dt,
    required this.precipitation,
  });

  factory Minutely.fromJson(Map<String, dynamic> json) {
    return Minutely(
      dt: json['dt'],
      precipitation: json['precipitation'],
    );
  }
}

class Hourly {
  final int dt;
  final num temp;
  final num feelsLike;
  final num pressure;
  final num humidity;
  final num clouds;
  final num visibility;
  final num windSpeed;
  final num windDeg;
  final List<WeatherData> weather;
  final num pop;

  Hourly({
    required this.dt,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.clouds,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    required this.weather,
    required this.pop,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) {
    return Hourly(
      dt: json['dt'],
      temp: json['temp'],
      feelsLike: json['feels_like'],
      pressure: json['pressure'],
      humidity: json['humidity'],
      clouds: json['clouds'],
      visibility: json['visibility'],
      windSpeed: json['wind_speed'],
      windDeg: json['wind_deg'],
      weather: List.generate(
        json['weather']?.length ?? 0, // TODO : Optimize
        (index) => WeatherData.fromJson(json['weather'][index]),
      ),
      pop: json['pop'],
    );
  }
}

class Daily {
  final int dt;
  final DailyTempData temp;
  final DailyFeelsLikeData feelsLike;
  final num pressure;
  final num humidity;
  final num windSpeed;
  final num windDeg;
  final List<WeatherData> weather;
  final num clouds;
  final num pop;
  final num uvi;

  Daily({
    required this.dt,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.weather,
    required this.clouds,
    required this.pop,
    required this.uvi,
  });

  factory Daily.fromJson(Map<String, dynamic> json) {
    return Daily(
      dt: json['dt'],
      temp: DailyTempData.fromJson(json['temp']),
      feelsLike: DailyFeelsLikeData.fromJson(json['feels_like']),
      pressure: json['pressure'],
      humidity: json['humidity'],
      windSpeed: json['wind_speed'],
      windDeg: json['wind_deg'],
      weather: List.generate(
        json['weather']?.length ?? 0, // TODO : Optimize
        (index) => WeatherData.fromJson(json['weather'][index]),
      ),
      clouds: json['clouds'],
      pop: json['pop'],
      uvi: json['uvi'],
    );
  }
}
