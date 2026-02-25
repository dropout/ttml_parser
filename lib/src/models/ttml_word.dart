/// A single timed word or syllable within a lyric line.
class TtmlWord {
  /// The time at which this word begins.
  final Duration begin;

  /// The time at which this word ends.
  final Duration end;

  /// The text content of this word.
  final String text;

  /// The duration of this word, computed as [end] minus [begin].
  Duration get duration => end - begin;

  /// Creates a [TtmlWord] with the given [begin], [end], and [text].
  const TtmlWord({
    required this.begin,
    required this.end,
    required this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtmlWord &&
          begin == other.begin &&
          end == other.end &&
          text == other.text;

  @override
  int get hashCode => Object.hash(begin, end, text);

  @override
  String toString() => 'TtmlWord(text: "$text", begin: $begin, end: $end)';
}