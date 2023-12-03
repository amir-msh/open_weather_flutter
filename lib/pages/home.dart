import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_weather_flutter/components/weather_indicator_painter/weather_indicator_painter.dart';
import 'package:open_weather_flutter/utils/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDay = false;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          setState(() {
            isDay = !isDay;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            gradient: LinearGradient(
              colors: isDay ? kDayGradient : kNightGradient,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Flex(
            direction: Axis.vertical,
            clipBehavior: Clip.none,
            children: [
              Expanded(
                child: Center(
                  child: WeatherIndicatorPainter(
                    scale: 1.1,
                    code: 2,
                    animation: true,
                    day: isDay,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 200,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Edit
                  crossAxisAlignment: CrossAxisAlignment.center,
                  direction: Axis.vertical,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          color: Colors.white24,
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 2.0,
                      color: isDay
                          ? Colors.white.withAlpha(75)
                          : Colors.black.withAlpha(75),
                      height: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        color: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
