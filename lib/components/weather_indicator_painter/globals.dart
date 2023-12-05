import 'dart:io';
import 'package:flutter/material.dart';

class Globals {
  static const animationEnabledDefault = false;

  static final bool isAntiAlias =
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static const bool defaultAnimationEnabled = false;

  static Paint sunPaint = Paint()
    ..isAntiAlias = isAntiAlias
    ..color = Colors.red;

  static Paint moonPaint = Paint()
    ..isAntiAlias = isAntiAlias
    ..color = const Color.fromARGB(255, 160, 150, 150);

  static Paint cloudPaint1 = Paint()
    ..isAntiAlias = isAntiAlias
    ..color = Colors.white;

  static Paint cloudPaint2 = Paint()
    ..isAntiAlias = isAntiAlias
    ..color = const Color.fromARGB(255, 100, 100, 100);

  static Paint cloudPaint3 = Paint()
    ..isAntiAlias = isAntiAlias
    ..color = const Color.fromARGB(255, 130, 130, 130);

  static const double startSnowFrom = -5; // Snow
  static const double startRainFrom = -5; // Rain
  static const double dropsDistance = 15; // Rain

  static Map<String, dynamic> toMap() {
    return {
      'isAntiAliase': isAntiAlias,
      'sunPaint': sunPaint,
      'moonPaint': moonPaint,
      'cloudPaint1': cloudPaint1,
      'cloudPaint2': cloudPaint2,
      'cloudPaint3': cloudPaint3,
      'startSnowFrom': startSnowFrom,
      'startRainFrom': startRainFrom,
      'dropsDistance': dropsDistance,
    };
  }

  //static const Duration cloudsDuration = const Duration(milliseconds: 750);
}
