import 'dart:async';
import 'dart:convert';
import 'dart:developer' as d;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_weather_flutter/components/flutter_earth.dart';
import 'package:open_weather_flutter/utils/credentials.dart';

import 'package:http/http.dart' as http;

typedef LatLonAltPosition = (double lat, double lon, double? alt);

class GlobeLocationPicker extends StatefulWidget {
  final LatLonAltPosition initialPosition;

  const GlobeLocationPicker({
    this.initialPosition = (0, 0, null),
    super.key,
  });

  @override
  State<GlobeLocationPicker> createState() => _GlobeLocationPickerState();
}

class _GlobeLocationPickerState extends State<GlobeLocationPicker>
    with SingleTickerProviderStateMixin {
  final _locationLabelNotifier = ValueNotifier<String?>('');
  final _locationChangeNotifier = ValueNotifier<LatLonAltPosition?>(null);
  final _locationPinNotifier = ValueNotifier<bool>(false);
  FlutterEarthController? earthController;
  bool isEarthAnimating = true;

  Timer? _timer;

  static const _earthAnimationLabelingTimeout = Duration(milliseconds: 360);
  static const _userSelectionLabelingTimeout = Duration(milliseconds: 750);
  Duration _newLocationLabelingTimeout = _earthAnimationLabelingTimeout;

  double degToRad(double deg) => (deg * pi) / 180;

  double radToDeg(double rad) => (rad * 180 / pi);

  Future _loadLocationLabel([bool checkTimer = true]) async {
    _locationPinNotifier.value = true;

    if ((_timer?.isActive ?? false) && checkTimer) return;
    _locationLabelNotifier.value = null;

    if (_locationChangeNotifier.value == null ||
        _locationChangeNotifier.value == null) {
      _locationLabelNotifier.value = '';
      return;
    }

    if (kDebugMode && false) {
      await Future.delayed(const Duration(milliseconds: 1000));
      _locationLabelNotifier.value =
          '${_locationChangeNotifier.value!.$1.toStringAsFixed(6)}'
          ', '
          '${_locationChangeNotifier.value!.$2.toStringAsFixed(6)}';
      return;
    }

    // label location here
    final cords = _locationChangeNotifier.value!;
    try {
      final uri = Uri.https(
        'api.mapbox.com',
        '/geocoding/v5/mapbox.places/${cords.$2},${cords.$1}.json',
        {
          'access_token': mapBoxApiKey,
        },
      );

      d.log('Labeling the pinned location');
      d.log('reverse geocoding uri: $uri');

      final result = await http.get(uri).timeout(
            const Duration(milliseconds: 3000),
          );

      if (result.statusCode ~/ 100 != 2) {
        _locationLabelNotifier.value = 'Unknown Error!';
      }

      final response = json.decode(result.body);

      final features = (response['features'] as List).toSet();

      // 'place_type': country, region, postcode, district, place, locality, neighborhood, address, and poi
      final ignoredTypes = {
        'postcode',
        'poi',
      };

      features.removeWhere(
        (feature) {
          final placeType = (feature["place_type"] as List).toSet();
          return placeType.intersection(ignoredTypes).isNotEmpty;
        },
      );

      // final String briefPlaceName = features.firstOrNull?['place_name'] ?? '';

      final placeContext = (features.firstOrNull?['context'] as List?);

      // (postcode) | (poi)
      final ignoredTypesRegExp = RegExp(
        ignoredTypes.map((type) => '($type)').join('|'),
        caseSensitive: false,
      );

      placeContext?.removeWhere(
        (e) {
          final id = e['id'] as String;
          return id.startsWith(ignoredTypesRegExp);
        },
      );

      final labelParts =
          placeContext?.map((part) => part['text'].toString()).toList();

      final briefPlaceName = labelParts?.join(', ') ?? '';

      // "place_name": "Mdr072, 825321, Serangdag, Tandwa, Chatra, Jharkhand, India",
      // "context": [
      //   {
      //     "id": "postcode.150752875",
      //     "mapbox_id": "dXJuOm1ieHBsYzpDUHhPYXc",
      //     "text": "825321"
      //   },
      //   {
      //     "id": "locality.3705358955",
      //     "mapbox_id": "dXJuOm1ieHBsYzozTnRLYXc",
      //     "text": "Serangdag"
      //   },
      //   {
      //     "id": "place.43804779",
      //     "mapbox_id": "dXJuOm1ieHBsYzpBcHhvYXc",
      //     "text": "Tandwa"
      //   },
      //   {
      //     "id": "district.1025643",
      //     "mapbox_id": "dXJuOm1ieHBsYzpENlpy",
      //     "wikidata": "Q1979499",
      //     "text": "Chatra"
      //   },
      //   {
      //     "id": "region.83051",
      //     "mapbox_id": "dXJuOm1ieHBsYzpBVVJy",
      //     "wikidata": "Q1184",
      //     "short_code": "IN-JH",
      //     "text": "Jharkhand"
      //   },
      //   {
      //     "id": "country.8811",
      //     "mapbox_id": "dXJuOm1ieHBsYzpJbXM",
      //     "wikidata": "Q668",
      //     "short_code": "in",
      //     "text": "India"
      //   }
      // ]

      if (briefPlaceName.isEmpty) {
        _locationLabelNotifier.value = 'Unknown place!';
      } else {
        _locationLabelNotifier.value = briefPlaceName;
      }
    } catch (e) {
      d.log('ERROR!', error: e);
      _locationLabelNotifier.value = 'No Internet!';
    }
  }

  void onLocationChange() {
    _timer?.cancel();
    _timer = Timer(
      _newLocationLabelingTimeout,
      () async {
        if (isEarthAnimating) {
          _newLocationLabelingTimeout = _userSelectionLabelingTimeout;
          _locationPinNotifier.value = true;
          await _loadLocationLabel();
          await Future.delayed(
            const Duration(milliseconds: 360),
          );
          setState(() {
            isEarthAnimating = false;
          });
          return;
        }
        await _loadLocationLabel();
      },
    );

    _locationPinNotifier.value = false;
  }

  @override
  void initState() {
    _locationChangeNotifier.addListener(onLocationChange);

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationLabelNotifier.dispose();
    _locationChangeNotifier.dispose();
    _locationPinNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: AbsorbPointer(
        absorbing: isEarthAnimating,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: StarsPainter(),
                          isComplex: true,
                          willChange: false,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white,
                              ],
                            ).createShader(rect);

                            // return const RadialGradient(
                            //   colors: [Colors.black, Colors.white],
                            //   stops: [0.32, 0.72],
                            //   center: Alignment(-1.41, -1.0),
                            //   radius: 1.5,
                            // ).createShader(rect);

                            // return const LinearGradient(
                            //   colors: [
                            //     Colors.black,
                            //     Colors.white,
                            //     Colors.white,
                            //   ],
                            //   stops: [0.15, 0.47, 1.0],
                            //   begin: Alignment(-1, -0.75),
                            //   end: Alignment(1, 0.3),
                            // ).createShader(rect);
                          },
                          child: FlutterEarth(
                            maxVertexCount: 1500,
                            url:
                                'http://mt0.google.com/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}',
                            radius: 200,
                            showPole: true,
                            onMapCreated: (
                              FlutterEarthController controller,
                            ) async {
                              await Future.delayed(
                                const Duration(milliseconds: 750),
                              );

                              earthController = controller;

                              controller.animateCamera(
                                panSpeed: 100,
                                riseSpeed: 0.45,
                                fallSpeed: 0.75,
                                riseZoom: 1.9,
                                fallZoom: 2.5,
                                newLatLon: LatLon(
                                  degToRad(widget.initialPosition.$1),
                                  degToRad(widget.initialPosition.$2),
                                ),
                              );
                            },
                            onCameraMove: (LatLon latlon, double z) {
                              final lat = radToDeg(latlon.latitude);
                              final lon = radToDeg(latlon.longitude);

                              _locationChangeNotifier.value = (lat, lon, z);
                              // d.log(
                              //   '${lat.toStringAsFixed(5)}, '
                              //   '${lon.toStringAsFixed(5)}',
                              // );
                            },
                            onTileStart: (tile) {
                              d.log('onTileStart');
                            },
                            onTileEnd: (tile) {
                              d.log('onTileEnd');
                              // _locationLabelNotifier.value =
                            },
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: IgnorePointer(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _locationPinNotifier,
                          builder: (context, value, child) {
                            return LocationMarker(
                              isPinned: value,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8 + MediaQuery.of(context).padding.bottom,
                      height: 45,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints.expand(width: 500),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOut,
                            opacity: isEarthAnimating ? 0.0 : 1.0,
                            child: RawMaterialButton(
                              onPressed: isEarthAnimating
                                  ? null
                                  : () {
                                      Navigator.pop<LatLonAltPosition>(
                                        context,
                                        _locationChangeNotifier.value,
                                      );
                                    },
                              disabledElevation: 0,
                              fillColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Select this location!',
                                style: TextStyle(
                                  fontSize: 17.5,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      top: MediaQuery.of(context).padding.top + 35,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ValueListenableBuilder<String?>(
                          valueListenable: _locationLabelNotifier,
                          builder: (context, label, child) {
                            late final Widget result;

                            if (label?.isNotEmpty ?? false) {
                              result = GestureDetector(
                                onTap: () async {
                                  final copyText =
                                      '(${_locationChangeNotifier.value?.$1.toStringAsFixed(6)}'
                                      ', '
                                      '${_locationChangeNotifier.value?.$2.toStringAsFixed(6)})'
                                      ': $label';
                                  d.log(
                                    'The location copied to the clipboard! : $copyText',
                                  );
                                  await Clipboard.setData(
                                    ClipboardData(text: copyText),
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 1250),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.fromLTRB(
                                          20,
                                          0,
                                          20,
                                          70,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 15,
                                        ),
                                        content: Text(
                                          'The location label copied to the clipboard!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  key: ValueKey(label),
                                  padding:
                                      const EdgeInsets.fromLTRB(7, 7, 13, 9),
                                  child: Row(
                                    key: ValueKey(label),
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.red[600]!,
                                      ),
                                      const SizedBox(width: 4.5),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              90,
                                        ),
                                        child: Text(
                                          label!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blueGrey[900]!,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              result = Padding(
                                key: ValueKey(label),
                                padding: const EdgeInsets.all(5),
                                child: const SizedBox.square(
                                  dimension: 30,
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              );
                            }

                            final isVisible = label?.isNotEmpty ?? true;

                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeInOut,
                              opacity: isVisible ? 1.0 : 0.0,
                              child: Container(
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.5),
                                  color: Colors.white.withOpacity(0.75),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 9,
                                      color: Colors.grey[900]!,
                                      blurStyle: BlurStyle.normal,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  clipBehavior: Clip.hardEdge,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    switchInCurve: Curves.easeInOut,
                                    switchOutCurve: Curves.easeInOut,
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: result,
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}

class StarsPainter extends CustomPainter {
  static final random = Random();

  double randBetween(double a, double b) {
    return random.nextDouble() * (b - a).abs() + a;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 1000; i++) {
      final hsv = HSLColor.fromAHSL(
        1.0,
        // randBetween(0.75, 0.95),
        randBetween(170, 230), // 190, 210
        randBetween(0.75, 0.99),
        randBetween(0.1, 1.0),
      );

      final blur = randBetween(1.2, 1.5);

      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        randBetween(1.2, 1.75),
        Paint()
          ..color = hsv.toColor()
          ..isAntiAlias = true
          ..imageFilter = ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
            tileMode: TileMode.decal,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(StarsPainter oldDelegate) => false;
}

class LocationMarker extends StatelessWidget {
  final Duration animationDuration;
  final Curve animationCurve;
  final bool isPinned;

  const LocationMarker({
    super.key,
    this.animationDuration = const Duration(milliseconds: 275),
    this.animationCurve = Curves.decelerate,
    this.isPinned = true,
  });

  @override
  Widget build(BuildContext context) {
    final transform = Matrix4.identity()
      ..translate(
        -0.2,
        isPinned ? -21 : -35,
      )
      ..scale(
        isPinned ? 1.0 : 1.2,
      );

    final double pointerRadius = isPinned ? 3.6 : 5;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: animationDuration,
          curve: animationCurve,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: isPinned ? 3 : 4,
                blurStyle: BlurStyle.normal,
                spreadRadius: isPinned ? 2 : 4,
              ),
            ],
          ),
          width: pointerRadius,
          height: pointerRadius,
        ),
        AnimatedContainer(
          duration: animationDuration,
          curve: animationCurve,
          transform: transform,
          transformAlignment: Alignment.center,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            shadows: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5,
              ),
            ],
            size: 37,
          ),
        ),
      ],
    );
  }
}
