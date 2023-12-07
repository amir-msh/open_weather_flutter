import 'package:flutter/material.dart';

class TodayForecastViewer extends StatelessWidget {
  final bool isDay;
  final String description;
  final String temperature;
  final String locationTitle;
  final bool isCurrentLocation;
  final VoidCallback? onLocationButtonPressed;
  final Widget weatherIndicator;

  const TodayForecastViewer({
    required this.isDay,
    required this.description,
    required this.temperature,
    required this.locationTitle,
    required this.isCurrentLocation,
    required this.onLocationButtonPressed,
    required this.weatherIndicator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        weatherIndicator,
        Transform.translate(
          offset: const Offset(0, -30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                temperature,
                textAlign: TextAlign.center,
                softWrap: false,
                style: TextStyle(
                  fontSize: 50,
                  color: isDay ? Colors.black : Colors.white,
                ),
              ),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: isDay ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              RawMaterialButton(
                onPressed: onLocationButtonPressed,
                elevation: 0,
                hoverElevation: 0,
                focusElevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                fillColor: isDay
                    ? Colors.white.withAlpha(100)
                    : Colors.black.withAlpha(150),
                splashColor: isDay ? Colors.white.withAlpha(150) : Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      locationTitle,
                      textAlign: TextAlign.center,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                        color: isDay ? Colors.blue[900] : Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      isCurrentLocation
                          ? Icons.location_on //my_location
                          : Icons.pin_drop, //Icons.location_off,
                      color: isDay
                          ? Colors.black.withAlpha(200)
                          : Colors.white.withAlpha(125),
                      size: 20,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
