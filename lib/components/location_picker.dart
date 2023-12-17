import 'dart:async';
import 'dart:developer' as d;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_weather_flutter/components/globe_location_picker.dart';

import 'package:open_weather_flutter/utils/credentials.dart';
import 'package:open_weather_flutter/weather/weather_bloc.dart';
import 'package:open_weather_flutter/weather/weather_state.dart';

import 'package:mapbox_search/mapbox_search.dart' as mb_search;
import 'package:mapbox_search/models/failure_response.dart'
    as mb_failure_response;
import 'package:mapbox_search/models/retrieve_response.dart';
import 'package:mapbox_search/models/suggestion_response.dart'
    as mb_suggestion_response;

typedef SuggestedPlaces = List<mb_suggestion_response.Suggestion>;

class LocationPicker extends StatefulWidget {
  final bool isDay;
  const LocationPicker({
    required this.isDay,
    super.key,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  static const searchTimerDuration = Duration(milliseconds: 1000);
  static const searchRequestTimeout = Duration(seconds: 10);
  final _searchBoxController = TextEditingController();
  final rand = Random();

  final _placeListController = ScrollController();

  final _searchBoxFocusNode = FocusNode();
  final _pageFocusNode = FocusNode();
  static const double topPadding = 20;

  Timer searchTimer = Timer(const Duration(seconds: 0), () {});

  final _suggestedPlacesNotifier = ValueNotifier<SuggestedPlaces?>([]);

  static final placesSearchBox = mb_search.SearchBoxAPI(
    apiKey: mapBoxApiKey,
    types: [
      mb_search.PlaceType.district,
      mb_search.PlaceType.locality,
      mb_search.PlaceType.neighborhood,
      mb_search.PlaceType.place,
      mb_search.PlaceType.poi,
      mb_search.PlaceType.region,
    ],
    limit: 10,
  );

  Future<void> showSearchBarSuggestions() async {
    String searchQuery = _searchBoxController.text;

    // set loading
    if (_suggestedPlacesNotifier.value != null) {
      _suggestedPlacesNotifier.value = null;
    }

    // {
    //   await Future.delayed(const Duration(milliseconds: 1200));
    //   _suggestedPlacesNotifier.value = List.generate(
    //     50,
    //     (i) => mb_search.Suggestion(
    //       name: 'Place Number $i',
    //       mapboxId: i.toString(),
    //       featureType: 'city',
    //       address: 'Place Number $i address',
    //       fullAddress: 'Place Number $i full address',
    //       placeFormatted: 'Place Number $i place formatted',
    //       context: null,
    //       language: 'en',
    //       maki: null,
    //       externalIds: mb_search.ExternalIds(),
    //       // <double>[Random().nextDouble() * 60, Random().nextDouble() * 60],
    //     ),
    //   );
    //   return;
    // }

    if (searchQuery.isNotEmpty) {
      final ({
        mb_failure_response.FailureResponse? failure,
        mb_suggestion_response.SuggestionResponse? success,
      }) result = await placesSearchBox.getSuggestions(searchQuery).timeout(
            searchRequestTimeout,
          );

      if (searchTimer.isActive) return;

      if (result.success == null || result.failure != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                result.failure?.message ??
                    result.failure?.error ??
                    "An unknown error occurred!",
              ),
            ),
          );
        }

        _suggestedPlacesNotifier.value = [];
        return;
      }

      final suggestions = result.success!.suggestions;

      final poiPlaces = <mb_search.Suggestion>[];
      final nonPoiPlaces = <mb_search.Suggestion>[];
      for (var place in suggestions) {
        if (place.featureType == 'poi') {
          poiPlaces.add(place);
        } else {
          nonPoiPlaces.add(place);
        }
      }

      final suggestedPlaces = nonPoiPlaces..addAll(poiPlaces);

      suggestedPlaces.removeWhere(
        (place) {
          return place.name.isEmpty;
        },
      );

      _suggestedPlacesNotifier.value = suggestedPlaces;

      if (_placeListController.hasClients) {
        _placeListController.jumpTo(0);
      }
    } else {
      searchTimer.cancel();
      _suggestedPlacesNotifier.value = [];
    }
  }

  Future<void> searchBoxOnChanged() async {
    debugPrint(' *** searchBox OnChanged *** ');

    if (_searchBoxController.text.isEmpty) {
      searchTimer.cancel();
      _suggestedPlacesNotifier.value = [];
      return;
    }

    _suggestedPlacesNotifier.value = null;

    try {
      if (searchTimer.isActive) {
        searchTimer.cancel();
      }

      searchTimer = Timer(
        searchTimerDuration,
        () {
          d.log('*** searchTimer finished ***');
          searchTimer.cancel();
          showSearchBarSuggestions();
        },
      );
    } catch (e) {
      d.log("Timer Error!", error: e);
    }
  }

  Color randomColor() {
    return Color(
      (rand.nextDouble() * 4294967296).floor() | 0xFFA0A0A0,
    );
  }

  Future<void> placeListItemClicked(int index) async {
    searchTimer.cancel();

    final selectedPlace = _suggestedPlacesNotifier.value![index];

    final ({
      mb_failure_response.FailureResponse? failure,
      RetrieveResonse? success,
    }) details = await placesSearchBox.getPlace(
      selectedPlace.mapboxId,
    );

    // TODO: Add loading

    if (details.success == null || details.failure != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(details.failure?.message ??
                    details.failure?.error ??
                    'An unknown error occurred!'
                // 'There is no internet connection!',
                ),
          ),
        );
      }
      return;
    }

    final cords = details.success!.features.first.geometry.coordinates;

    d.log('manual location selected: ${cords.lat}, ${cords.long}');

    if (context.mounted) {
      BlocProvider.of<WeatherCubit>(context).getManualLocationWeather(
        cords.lat,
        cords.long,
      );
      Navigator.of(context).pop();
    }
  }

  Widget placeListItemBuilder(BuildContext context, int index) {
    final suggestion = _suggestedPlacesNotifier.value![index];

    return Container(
      padding: const EdgeInsets.only(bottom: 2.5),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          color: (widget.isDay)
              ? Colors.black.withAlpha(120)
              : Colors.white.withAlpha(60),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: ListTile(
        isThreeLine: true,
        title: Text(
          suggestion.name,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 5,
              )
            ],
          ),
        ),
        subtitle: Text(
          suggestion.placeFormatted,

          // suggestion.matchingPlaceName ??
          //     //suggestedPlaces[index].text ??
          //     suggestion.placeName ??

          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 3,
              )
            ],
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 0 /*12*/),
          child: Icon(
            Icons.edit_location, //Icons.pin_drop,
            color: randomColor(),
            size: 30,
          ),
        ),
        onTap: () => placeListItemClicked(index),
      ),
    );
  }

  @override
  void dispose() {
    _suggestedPlacesNotifier.dispose();
    _searchBoxController.dispose();
    _searchBoxFocusNode.dispose();
    searchTimer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        _searchBoxFocusNode.requestFocus();
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        primary: true,
        body: PopScope(
          onPopInvoked: (didPop) async {
            searchTimer.cancel();
            if (didPop) return;
            Navigator.of(context).pop();
          },
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                Positioned(
                  left: 20,
                  top: topPadding,
                  right: 20,
                  height: 70,
                  child: TextField(
                    focusNode: _searchBoxFocusNode,
                    showCursor: true,
                    autocorrect: true,
                    autofocus: false,
                    enableSuggestions: true,
                    scrollPhysics: const BouncingScrollPhysics(),
                    inputFormatters: <TextInputFormatter>[
                      // FilteringTextInputFormatter.deny(
                      //   RegExp('[`~!@#\$%^&*()\-+_=\'"\.\\\/]'),
                      // ),
                      FilteringTextInputFormatter.deny(
                        RegExp('[`~!@#\$%^&*()-+_=\'".\\/]'),
                      ),
                    ],
                    maxLength: 25,
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.bottom,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                        fontSize: 20,
                        color:
                            Colors.black.withAlpha(200) //Colors.white // (main)
                        ),
                    cursorColor: Colors.black,
                    cursorWidth: 2,
                    cursorRadius: const Radius.circular(1),
                    controller: _searchBoxController,
                    decoration: InputDecoration(
                      fillColor: Colors.white.withAlpha(150),
                      filled: true,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                      ),

                      //<test> debug

                      prefixIcon: IconButton(
                        icon: const Icon(
                          Icons.my_location,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: () async {
                          searchTimer.cancel();

                          BlocProvider.of<WeatherCubit>(context)
                              .getCurrentLocationWeather();
                          Navigator.of(context).pop();
                        },
                      ),

                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),

                      // Icons.cancel , Icons.close , Icons.clear , Icons.search ,Icons.edit_location

                      counter: const Text(''),
                      hintText: 'Search Location',
                      hintStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black.withAlpha(150),
                      ),
                    ),
                    onChanged: (String text) async {
                      searchBoxOnChanged();
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  top: topPadding + 60,
                  right: 0,
                  bottom: MediaQuery.of(context)
                      .viewInsets
                      .bottom, // TODO: check sizing
                  child: RepaintBoundary(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, 0.025, 0.975, 1],
                          colors: <Color>[
                            Colors.black.withAlpha(0),
                            Colors.black.withAlpha(255),
                            Colors.black.withAlpha(255),
                            Colors.black.withAlpha(0)
                            //Colors.red, Colors.green, Colors.blue
                          ],
                        ).createShader(bounds);
                      },
                      child: ValueListenableBuilder<SuggestedPlaces?>(
                        valueListenable: _suggestedPlacesNotifier,
                        builder: (context, value, child) {
                          late final Widget searchResult;

                          if (value == null) {
                            searchResult = const Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            );
                          } else if (value.isEmpty &&
                              _searchBoxController.text.isEmpty) {
                            searchResult = Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: topPadding,
                                ),
                                child: RawMaterialButton(
                                  onPressed: () async {
                                    final selectedPosition =
                                        await Navigator.of(context)
                                            .push<LatLonAltPosition?>(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          final state =
                                              BlocProvider.of<WeatherCubit>(
                                                      context)
                                                  .state;

                                          if (state is WeatherStatusOk) {
                                            return GlobeLocationPicker(
                                              initialPosition: (
                                                state.weatherData.lat
                                                    .toDouble(),
                                                state.weatherData.lon
                                                    .toDouble(),
                                                null,
                                              ),
                                            );
                                          } else {
                                            return const GlobeLocationPicker();
                                          }
                                        },
                                      ),
                                    );

                                    if (selectedPosition != null &&
                                        context.mounted) {
                                      FocusScope.of(context)
                                          .requestFocus(_pageFocusNode);

                                      BlocProvider.of<WeatherCubit>(context)
                                          .getManualLocationWeather(
                                        selectedPosition.$1,
                                        selectedPosition.$2,
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  fillColor: Colors.white.withOpacity(0.9),
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 8, 14, 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.map_outlined),
                                      SizedBox(width: 6),
                                      Text('Select location on map'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (value.isEmpty &&
                              _searchBoxController.text.isNotEmpty) {
                            searchResult = Center(
                              child: Text(
                                'No location was found!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  shadows: const <Shadow>[
                                    Shadow(
                                      color: Colors.black87,
                                      blurRadius: 6,
                                      offset: Offset(0, 1),
                                    )
                                  ],
                                  fontSize: 18,
                                ),
                              ),
                            );
                          } else if (value.isNotEmpty) {
                            searchResult = ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 15),
                              physics: const BouncingScrollPhysics(),
                              controller: _placeListController,
                              separatorBuilder: (
                                BuildContext context,
                                int index,
                              ) {
                                return const SizedBox(height: 10);
                              },
                              itemCount: value.length,
                              itemBuilder: placeListItemBuilder,
                            );
                          } else {
                            searchResult = const SizedBox();
                          }

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 666),
                            child: searchResult,
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
