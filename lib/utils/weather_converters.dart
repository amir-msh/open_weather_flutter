double kelvinToCelsius(num kelvin) {
  return kelvin - 273.15;
}

String kelvinToCelsiusString(
  num kelvin, [
  int fractionDigits = 0,
]) {
  return kelvinToCelsius(kelvin.toDouble()).toStringAsFixed(fractionDigits);
}

DateTime dtToDateTime(int dt, {bool isUtc = false}) {
  return DateTime.fromMillisecondsSinceEpoch(
    dt * 1000,
    isUtc: isUtc,
  );
}

String humanizeDescription(
  String description,
) {
  return description.replaceAll('/', ', ').replaceAll('_', ' ').trim();
}
