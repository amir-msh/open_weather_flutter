import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:open_weather_flutter/http_helpers/weather/exceptions.dart';
import 'weather.dart';

// sample-location (Tehran): 35.845528,50.964009

/*
https://api.openweathermap.org/data/2.5/onecall?lat={lat}&lon={lon}&
exclude={part}&appid={YOUR API KEY}
*/

class WeatherHttpHepler {
  final String apiToken;
  const WeatherHttpHepler(this.apiToken);

  static const baseUri = 'https://api.openweathermap.org/data/2.5/onecall';

  Future<Weather> fetchWeather(double latitude, double longitude) async {
    final http.Response response = await http.get(
      Uri.parse('$baseUri?appid=$apiToken&lat=$latitude&lon=$longitude'),
    );

    if (response.statusCode ~/ 100 == 2) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw ResponseException();
    }
  }
}
