import 'package:flutter/foundation.dart';
import 'package:ttml_parser/ttml_parser.dart';

/// An immutable snapshot of playback and lyric state.
@immutable
class PlayerState {
  /// The current playback position.
  final Duration position;

  /// The total duration of the track.
  final Duration duration;

  /// Whether audio is currently playing.
  final bool isPlaying;

  /// The lyric line active at [position], or `null` if none.
  final TtmlLine? activeLine;

  /// The index of [activeLine] in the document's lines list, or `-1` if none.
  final int activeLineIndex;

  const PlayerState({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.activeLine,
    required this.activeLineIndex,
  });
}