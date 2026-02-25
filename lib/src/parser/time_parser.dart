import '../exceptions/ttml_parse_exception.dart';

/// Parses a TTML time string into a [Duration].
///
/// Accepts two formats:
/// - `MM:SS.mmm` (two colon-separated parts)
/// - `HH:MM:SS.mmm` (three colon-separated parts)
///
/// Throws [TtmlParseException] if the string is not a recognised format.
Duration parseTime(String s) {
  final parts = s.split(':');

  try {
    switch (parts.length) {
      case 2:
        final minutes = int.parse(parts[0]);
        final secondsFraction = double.parse(parts[1]);
        final milliseconds = (secondsFraction * 1000).round();
        return Duration(
          minutes: minutes,
          milliseconds: milliseconds,
        );

      case 3:
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final secondsFraction = double.parse(parts[2]);
        final milliseconds = (secondsFraction * 1000).round();
        return Duration(
          hours: hours,
          minutes: minutes,
          milliseconds: milliseconds,
        );

      default:
        throw TtmlParseException(
          'Invalid time format "$s": expected MM:SS.mmm or HH:MM:SS.mmm',
        );
    }
  } on TtmlParseException {
    rethrow;
  } on FormatException catch (e) {
    throw TtmlParseException(
      'Invalid time format "$s": ${e.message}',
      cause: e,
    );
  }
}