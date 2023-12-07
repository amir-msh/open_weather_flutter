import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_weather_flutter/http_helpers/weather/weather_http_helper.dart';
import 'package:open_weather_flutter/weather/weather_state.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherCubit extends Cubit<WeatherStatus> {
  bool isCurrentLocation = true;
  static const locationTimeout = Duration(seconds: 10);
  final WeatherHttpHepler _weatherHelper;

  WeatherCubit(this._weatherHelper) : super(WeatherStatusInitial());

  ({double lat, double lon}) getLatestLocation(final WeatherStatusOk data) {
    return (
      lat: data.weatherData.lat.toDouble(),
      lon: data.weatherData.lon.toDouble(),
    );
  }

  Future refreshWeatherData() async {
    if (state is! WeatherStatusOk) return;

    final okState = state as WeatherStatusOk;
    final latestLocation = getLatestLocation(okState);

    emit(WeatherStatusLoading());

    try {
      emit(
        WeatherStatusOk(
          weatherData: await _weatherHelper.fetchWeather(
            latestLocation.lat,
            latestLocation.lon,
          ),
          isCurrentLocation: okState.isCurrentLocation,
        ),
      );
    } on TimeoutException {
      emit(WeatherStatusError(WeatherStatusErrors.noInternet));
    } on SocketException {
      emit(WeatherStatusError(WeatherStatusErrors.noInternet));
    } catch (e, s) {
      log('Error', stackTrace: s);
      emit(WeatherStatusError());
    }
  }

  Future getManualLocationWeather(double lat, double lon) async {
    // if (state is! WeatherStatusOk) return;

    try {
      emit(
        WeatherStatusOk(
          weatherData: await _weatherHelper.fetchWeather(lat, lon),
          isCurrentLocation: false,
        ),
      );
      isCurrentLocation = false;
    } on TimeoutException {
      emit(WeatherStatusError(WeatherStatusErrors.noInternet));
    } on SocketException {
      emit(WeatherStatusError(WeatherStatusErrors.noInternet));
    } catch (e, s) {
      log('Error', stackTrace: s);
      emit(WeatherStatusError());
    }
  }

  Future getCurrentLocationWeather() async {
    emit(WeatherStatusLoading());

    if (!await Permission.locationWhenInUse.request().isGranted) {
      emit(WeatherStatusError(WeatherStatusErrors.noAccess));
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: locationTimeout,
      );
      isCurrentLocation = true;

      try {
        emit(
          WeatherStatusOk(
            weatherData: await _weatherHelper.fetchWeather(
              position.latitude,
              position.longitude,
            ),
            isCurrentLocation: true,
          ),
        );
        isCurrentLocation = true;
      } on TimeoutException {
        emit(WeatherStatusError(WeatherStatusErrors.noInternet));
      } on SocketException {
        emit(WeatherStatusError(WeatherStatusErrors.noInternet));
      } catch (e, s) {
        log('Error', stackTrace: s);
        emit(WeatherStatusError());
      }
    } catch (e) {
      emit(WeatherStatusError(WeatherStatusErrors.noLocation));
    }
  }
}

// abstract class WeatherException implements Exception {
//   WeatherException();
// }

// class NoLocationWeatherException extends WeatherException {}

// class NoLocationAccessWeatherException extends WeatherException {}
